require 'cmd/missing'

class Volumes
  def initialize
    @volumes = get_mounts
  end

  def which path
    vols = get_mounts path

    # no volume found
    if vols.empty?
      return -1
    end

    vol_index = @volumes.index(vols[0])
    # volume not found in volume list
    if vol_index.nil?
      return -1
    end
    return vol_index
  end

  def get_mounts path=nil
    vols = []
    # get the volume of path, if path is nil returns all volumes
    raw_df = `/bin/df -P #{path}`
    raw_df.split("\n").each do |line|
      case line
      # regex matches: /dev/disk0s2   489562928 440803616  48247312    91%    /
      when /^(.*)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]{1,3}\%)\s+(.*)/
        vols << $6
      end
    end
    return vols
  end
end


class Checks
  # Sorry for the lack of an indent here, the diff would have been unreadable.

############# HELPERS
def remove_trailing_slash s
  (s[s.length-1] == '/') ? s[0,s.length-1] : s
end


def paths
  @paths ||= ENV['PATH'].split(':').collect do |p|
    begin
      remove_trailing_slash(File.expand_path(p))
    rescue ArgumentError
      onoe "The following PATH component is invalid: #{p}"
    end
  end.uniq.compact
end

  # Finds files in HOMEBREW_PREFIX *and* /usr/local.
  # Specify paths relative to a prefix eg. "include/foo.h".
  # Sets @found for your convenience.
  def find_relative_paths *relative_paths
    @found = %W[#{HOMEBREW_PREFIX} /usr/local].uniq.inject([]) do |found, prefix|
      found + relative_paths.map{|f| File.join(prefix, f) }.select{|f| File.exist? f }
    end
  end

  def inject_file_list(list, str)
    list.inject(str) { |s, f| s << "    #{f}\n" }
  end
############# END HELPERS

# See https://github.com/mxcl/homebrew/pull/9986
def check_path_for_trailing_slashes
  bad_paths = ENV['PATH'].split(':').select{|p| p[p.length-1, p.length] == '/'}
  return if bad_paths.empty?
  s = <<-EOS.undent
    Some directories in your path end in a slash.
    Directories in your path should not end in a slash. This can break other
    doctor checks. The following directories should be edited:
  EOS
  bad_paths.each{|p| s << "    #{p}"}
  s
end

# Installing MacGPG2 interferes with Homebrew in a big way
# http://sourceforge.net/projects/macgpg2/files/
def check_for_macgpg2
  if %w{/Applications/start-gpg-agent.app
        /Library/Receipts/libiconv1.pkg
        /usr/local/MacGPG2}.any? { |f| File.exist? f }
    <<-EOS.undent
      You may have installed MacGPG2 via the package installer.
      Several other checks in this script will turn up problems, such as stray
      dylibs in /usr/local and permissions issues with share and man in /usr/local/.
    EOS
  end unless File.exist? '/usr/local/MacGPG2/share/gnupg/VERSION'
end

def check_for_stray_dylibs
  unbrewed_dylibs = Dir['/usr/local/lib/*.dylib'].select { |f| File.file? f and not File.symlink? f }

  # Dylibs which are generally OK should be added to this list,
  # with a short description of the software they come with.
  white_list = {
    "libfuse.2.dylib" => "MacFuse",
    "libfuse_ino64.2.dylib" => "MacFuse"
  }

  bad_dylibs = unbrewed_dylibs.reject {|d| white_list.key? File.basename(d) }
  return if bad_dylibs.empty?

  s = <<-EOS.undent
    Unbrewed dylibs were found in /usr/local/lib.
    If you didn't put them there on purpose they could cause problems when
    building Homebrew formulae, and may need to be deleted.

    Unexpected dylibs:
  EOS
  inject_file_list(bad_dylibs, s)
end

def check_for_stray_static_libs
  unbrewed_alibs = Dir['/usr/local/lib/*.a'].select { |f| File.file? f and not File.symlink? f }

  # Static libs which are generally OK should be added to this list,
  # with a short description of the software they come with.
  white_list = {
    "libsecurity_agent_client.a" => "OS X 10.8.2 Supplemental Update",
    "libsecurity_agent_server.a" => "OS X 10.8.2 Supplemental Update"
  }

  bad_alibs = unbrewed_alibs.reject {|d| white_list.key? File.basename(d) }
  return if bad_alibs.empty?

  s = <<-EOS.undent
    Unbrewed static libraries were found in /usr/local/lib.
    If you didn't put them there on purpose they could cause problems when
    building Homebrew formulae, and may need to be deleted.

    Unexpected static libraries:
  EOS
  inject_file_list(bad_alibs, s)
end

def check_for_stray_pcs
  unbrewed_pcs = Dir['/usr/local/lib/pkgconfig/*.pc'].select { |f| File.file? f and not File.symlink? f }

  # Package-config files which are generally OK should be added to this list,
  # with a short description of the software they come with.
  white_list = { }

  bad_pcs = unbrewed_pcs.reject {|d| white_list.key? File.basename(d) }
  return if bad_pcs.empty?

  s = <<-EOS.undent
    Unbrewed .pc files were found in /usr/local/lib/pkgconfig.
    If you didn't put them there on purpose they could cause problems when
    building Homebrew formulae, and may need to be deleted.

    Unexpected .pc files:
  EOS
  inject_file_list(bad_pcs, s)
end

def check_for_stray_las
  unbrewed_las = Dir['/usr/local/lib/*.la'].select { |f| File.file? f and not File.symlink? f }

  white_list = {
    "libfuse.la" => "MacFuse",
    "libfuse_ino64.la" => "MacFuse",
  }

  bad_las = unbrewed_las.reject {|d| white_list.key? File.basename(d) }
  return if bad_las.empty?

  s = <<-EOS.undent
    Unbrewed .la files were found in /usr/local/lib.
    If you didn't put them there on purpose they could cause problems when
    building Homebrew formulae, and may need to be deleted.

    Unexpected .la files:
  EOS
  inject_file_list(bad_las, s)
end

def check_for_other_package_managers
  ponk = MacOS.macports_or_fink
  unless ponk.empty?
    <<-EOS.undent
      You have MacPorts or Fink installed:
        #{ponk.join(", ")}

      This can cause trouble. You don't have to uninstall them, but you may want to
      temporarily move them out of the way, e.g.

        sudo mv /opt/local ~/macports
    EOS
  end
end

def check_for_broken_symlinks
  require 'keg'
  broken_symlinks = []
  Keg::PRUNEABLE_DIRECTORIES.each do |d|
    next unless d.directory?
    d.find do |pn|
      broken_symlinks << pn if pn.symlink? and pn.readlink.expand_path.to_s =~ /^#{HOMEBREW_PREFIX}/ and not pn.exist?
    end
  end
  unless broken_symlinks.empty? then <<-EOS.undent
    Broken symlinks were found. Remove them with `brew prune`:
      #{broken_symlinks * "\n      "}
    EOS
  end
end

def check_for_latest_xcode
  if not MacOS::Xcode.installed?
    if MacOS.version >= 10.7
      if not MacOS::CLT.installed?
        <<-EOS.undent
        No developer tools installed
        You should install the Command Line Tools: http://connect.apple.com
        EOS
      elsif not MacOS::CLT.latest_version?
        <<-EOS.undent
        A newer Command Line Tools for Xcode release is avaliable
        You should install the latest version from: http://connect.apple.com
        EOS
      end
    else
      <<-EOS.undent
      Xcode not installed
      Most stuff needs Xcode to build: http://developer.apple.com/xcode/
      EOS
    end
  elsif MacOS::Xcode.version < MacOS::Xcode.latest_version then <<-EOS.undent
    Your Xcode (#{MacOS::Xcode.version}) is outdated
    Please install Xcode #{MacOS::Xcode.latest_version}.
    EOS
  end
end

def check_for_stray_developer_directory
  # if the uninstaller script isn't there, it's a good guess neither are
  # any troublesome leftover Xcode files
  if MacOS::Xcode.version >= "4.3" and File.exist? "/Developer/Library/uninstall-developer-folder"
    return <<-EOS.undent
    You have leftover files from an older version of Xcode.
    You should delete them using:
      /Developer/Library/uninstall-developer-folder
    EOS
  end
end

def check_cc
  unless MacOS::CLT.installed?
    if MacOS::Xcode.version >= "4.3"
      return <<-EOS.undent
        Experimental support for using Xcode without the "Command Line Tools".
        You have only installed Xcode. If stuff is not building, try installing the
        "Command Line Tools for Xcode" package provided by Apple.
      EOS
    else
      return <<-EOS.undent
        No compiler found in /usr/bin!
      EOS
    end
  end
end

def check_standard_compilers
  return if check_for_latest_xcode # only check if Xcode is up to date
  compiler_status = MacOS.compilers_standard?
  if not compiler_status and not compiler_status.nil? then <<-EOS.undent
    Your compilers are different from the standard versions for your Xcode.
    If you have Xcode 4.3 or newer, you should install the Command Line Tools for
    Xcode from within Xcode's Download preferences.
    Otherwise, you should reinstall Xcode.
    EOS
  end
end

def __check_subdir_access base
  target = HOMEBREW_PREFIX+base
  return unless target.exist?

  cant_read = []

  target.find do |d|
    next unless d.directory?
    cant_read << d unless d.writable_real?
  end

  cant_read.sort!
  if cant_read.length > 0 then
    s = <<-EOS.undent
    Some directories in #{target} aren't writable.
    This can happen if you "sudo make install" software that isn't managed
    by Homebrew. If a brew tries to add locale information to one of these
    directories, then the install will fail during the link step.
    You should probably `chown` them:

    EOS
    cant_read.each{ |f| s << "    #{f}\n" }
    s
  end
end

def check_access_usr_local
  return unless HOMEBREW_PREFIX.to_s == '/usr/local'

  unless File.writable_real?("/usr/local") then <<-EOS.undent
    The /usr/local directory is not writable.
    Even if this directory was writable when you installed Homebrew, other
    software may change permissions on this directory. Some versions of the
    "InstantOn" component of Airfoil are known to do this.

    You should probably change the ownership and permissions of /usr/local
    back to your user account.
    EOS
  end
end

def check_access_share_locale
  __check_subdir_access 'share/locale'
end

def check_access_share_man
  __check_subdir_access 'share/man'
end

def __check_folder_access base, msg
  folder = HOMEBREW_PREFIX+base
  if folder.exist? and not folder.writable_real?
    <<-EOS.undent
      #{folder} isn't writable.
      This can happen if you "sudo make install" software that isn't managed
      by Homebrew.

      #{msg}

      You should probably `chown` #{folder}
    EOS
  end
end

def check_access_pkgconfig
  __check_folder_access 'lib/pkgconfig',
  'If a brew tries to write a .pc file to this directory, the install will\n'+
  'fail during the link step.'
end

def check_access_include
  __check_folder_access 'include',
  'If a brew tries to write a header file to this directory, the install will\n'+
  'fail during the link step.'
end

def check_access_etc
  __check_folder_access 'etc',
  'If a brew tries to write a file to this directory, the install will\n'+
  'fail during the link step.'
end

def check_access_share
  __check_folder_access 'share',
  'If a brew tries to write a file to this directory, the install will\n'+
  'fail during the link step.'
end

def check_access_logs
  folder = Pathname.new('~/Library/Logs/Homebrew')
  if folder.exist? and not folder.writable_real?
    <<-EOS.undent
      #{folder} isn't writable.
      This can happen if you "sudo make install" software that isn't managed
      by Homebrew.

      Homebrew writes debugging logs to this location.

      You should probably `chown` #{folder}
    EOS
  end
end

def check_usr_bin_ruby
  if /^1\.9/.match RUBY_VERSION
    <<-EOS.undent
      Ruby version #{RUBY_VERSION} is unsupported.
      Homebrew is developed and tested on Ruby 1.8.x, and may not work correctly
      on other Rubies. Patches are accepted as long as they don't break on 1.8.x.
    EOS
  end
end

def check_homebrew_prefix
  unless HOMEBREW_PREFIX.to_s == '/usr/local'
    <<-EOS.undent
      Your Homebrew is not installed to /usr/local
      You can install Homebrew anywhere you want, but some brews may only build
      correctly if you install in /usr/local. Sorry!
    EOS
  end
end

def check_xcode_prefix
  prefix = MacOS::Xcode.prefix
  return if prefix.nil?
  if prefix.to_s.match(' ')
    <<-EOS.undent
      Xcode is installed to a directory with a space in the name.
      This will cause some formulae to fail to build.
    EOS
  end
end

def check_xcode_prefix_exists
  prefix = MacOS::Xcode.prefix
  return if prefix.nil?
  unless prefix.exist?
    <<-EOS.undent
      The folder Xcode is reportedly installed to doesn't exist:
        #{prefix}
      You may need to `xcode-select` the proper path if you have moved Xcode.
    EOS
  end
end

def check_xcode_select_path
  # with the advent of CLT-only support, we don't need xcode-select

  if MacOS::Xcode.bad_xcode_select_path?
    <<-EOS.undent
      Your xcode-select path is set to /
      You must unset it or builds will hang:
        sudo rm /usr/share/xcode-select/xcode_dir_*
    EOS
  elsif not MacOS::CLT.installed? and not File.file? "#{MacOS::Xcode.folder}/usr/bin/xcodebuild"
    path = MacOS.app_with_bundle_id(MacOS::Xcode::V4_BUNDLE_ID) || MacOS.app_with_bundle_id(MacOS::Xcode::V3_BUNDLE_ID)
    path = '/Developer' if path.nil? or not path.directory?
    <<-EOS.undent
      Your Xcode is configured with an invalid path.
      You should change it to the correct path:
        sudo xcode-select -switch #{path}
    EOS
  end
end

def check_user_path_1
  $seen_prefix_bin = false
  $seen_prefix_sbin = false
  seen_usr_bin = false

  out = nil

  paths.each do |p|
    case p
    when '/usr/bin'
      seen_usr_bin = true
      unless $seen_prefix_bin
        # only show the doctor message if there are any conflicts
        # rationale: a default install should not trigger any brew doctor messages
        conflicts = Dir["#{HOMEBREW_PREFIX}/bin/*"].
            map{ |fn| File.basename fn }.
            select{ |bn| File.exist? "/usr/bin/#{bn}" }

        if conflicts.size > 0
          out = <<-EOS.undent
            /usr/bin occurs before #{HOMEBREW_PREFIX}/bin
            This means that system-provided programs will be used instead of those
            provided by Homebrew. The following tools exist at both paths:

                #{conflicts * "\n                "}

            Consider amending your PATH so that #{HOMEBREW_PREFIX}/bin
            occurs before /usr/bin in your PATH.
          EOS
        end
      end
    when "#{HOMEBREW_PREFIX}/bin"
      $seen_prefix_bin = true
    when "#{HOMEBREW_PREFIX}/sbin"
      $seen_prefix_sbin = true
    end
  end
  out
end

def check_user_path_2
  unless $seen_prefix_bin
    <<-EOS.undent
      Homebrew's bin was not found in your path.
      Consider amending your PATH variable so it contains:
        #{HOMEBREW_PREFIX}/bin
    EOS
  end
end

def check_user_path_3
  # Don't complain about sbin not being in the path if it doesn't exist
  sbin = (HOMEBREW_PREFIX+'sbin')
  if sbin.directory? and sbin.children.length > 0
    unless $seen_prefix_sbin
      <<-EOS.undent
        Homebrew's sbin was not found in your path.
        Consider amending your PATH variable so it contains:
          #{HOMEBREW_PREFIX}/sbin
      EOS
    end
  end
end

def check_user_curlrc
  if %w[CURL_HOME HOME].any?{|key| ENV[key] and File.exists? "#{ENV[key]}/.curlrc" } then <<-EOS.undent
    You have a curlrc file
    If you have trouble downloading packages with Homebrew, then maybe this
    is the problem? If the following command doesn't work, then try removing
    your curlrc:
      curl http://github.com
    EOS
  end
end

def check_which_pkg_config
  binary = which 'pkg-config'
  return if binary.nil?

  mono_config = Pathname.new("/usr/bin/pkg-config")
  if mono_config.exist? && mono_config.realpath.to_s.include?("Mono.framework") then <<-EOS.undent
    You have a non-Homebrew 'pkg-config' in your PATH:
      /usr/bin/pkg-config => #{mono_config.realpath}

    This was most likely created by the Mono installer. `./configure` may
    have problems finding brew-installed packages using this other pkg-config.
    EOS
  elsif binary.to_s != "#{HOMEBREW_PREFIX}/bin/pkg-config" then <<-EOS.undent
    You have a non-Homebrew 'pkg-config' in your PATH:
      #{binary}

    `./configure` may have problems finding brew-installed packages using
    this other pkg-config.
    EOS
  end
end

def check_for_gettext
  find_relative_paths("lib/libgettextlib.dylib",
                      "lib/libintl.dylib",
                      "include/libintl.h")

  return if @found.empty?

  # Our gettext formula will be caught by check_linked_keg_only_brews
  f = Formula.factory("gettext") rescue nil
  return if f and f.linked_keg.directory? and @found.all? do |path|
    Pathname.new(path).realpath.to_s.start_with? "#{HOMEBREW_CELLAR}/gettext"
  end

  s = <<-EOS.undent_________________________________________________________72
      gettext files detected at a system prefix
      These files can cause compilation and link failures, especially if they
      are compiled with improper architectures. Consider removing these files:
      EOS
  inject_file_list(@found, s)
end

def check_for_iconv
  unless find_relative_paths("lib/libiconv.dylib", "include/iconv.h").empty?
    if (f = Formula.factory("libiconv") rescue nil) and f.linked_keg.directory?
      if not f.keg_only? then <<-EOS.undent
        A libiconv formula is installed and linked
        This will break stuff. For serious. Unlink it.
        EOS
      else
        # NOOP because: check_for_linked_keg_only_brews
      end
    else
      s = <<-EOS.undent_________________________________________________________72
          libiconv files detected at a system prefix other than /usr
          Homebrew doesn't provide a libiconv formula, and expects to link against
          the system version in /usr. libiconv in other prefixes can cause
          compile or link failure, especially if compiled with improper
          architectures. OS X itself never installs anything to /usr/local so
          it was either installed by a user or some other third party software.

          tl;dr: delete these files:
          EOS
      inject_file_list(@found, s)
    end
  end
end

def check_for_config_scripts
  return unless HOMEBREW_CELLAR.exist?
  real_cellar = HOMEBREW_CELLAR.realpath

  config_scripts = []

  whitelist = %W[/usr/bin /usr/sbin /usr/X11/bin /usr/X11R6/bin /opt/X11/bin #{HOMEBREW_PREFIX}/bin #{HOMEBREW_PREFIX}/sbin]
  whitelist.map! { |d| d.downcase }

  paths.each do |p|
    next if whitelist.include? p.downcase
    next if p =~ %r[^(#{real_cellar.to_s}|#{HOMEBREW_CELLAR.to_s})] if real_cellar

    configs = Dir["#{p}/*-config"]
    # puts "#{p}\n    #{configs * ' '}" unless configs.empty?
    config_scripts << [p, configs.collect {|p| File.basename(p)}] unless configs.empty?
  end

  unless config_scripts.empty?
    s = <<-EOS.undent
      "config" scripts exist outside your system or Homebrew directories.
      `./configure` scripts often look for *-config scripts to determine if
      software packages are installed, and what additional flags to use when
      compiling and linking.

      Having additional scripts in your path can confuse software installed via
      Homebrew if the config script overrides a system or Homebrew provided
      script of the same name. We found the following "config" scripts:

    EOS

    config_scripts.each do |pair|
      dn = pair[0]
      pair[1].each do |fn|
        s << "    #{dn}/#{fn}\n"
      end
    end
    s
  end
end

def check_for_DYLD_LIBRARY_PATH
  if ENV['DYLD_LIBRARY_PATH']
    <<-EOS.undent
      Setting DYLD_LIBRARY_PATH can break dynamic linking.
      You should probably unset it.
    EOS
  end
end

def check_for_DYLD_FALLBACK_LIBRARY_PATH
  if ENV['DYLD_FALLBACK_LIBRARY_PATH']
    <<-EOS.undent
      Setting DYLD_FALLBACK_LIBRARY_PATH can break dynamic linking.
      You should probably unset it.
    EOS
  end
end

def check_for_DYLD_INSERT_LIBRARIES
  if ENV['DYLD_INSERT_LIBRARIES']
    <<-EOS.undent
      Setting DYLD_INSERT_LIBRARIES can cause Go builds to fail.
      Having this set is common if you use this software:
        http://asepsis.binaryage.com/
    EOS
  end
end

def check_for_symlinked_cellar
  return unless HOMEBREW_CELLAR.exist?
  if HOMEBREW_CELLAR.symlink?
    <<-EOS.undent
      Symlinked Cellars can cause problems.
      Your Homebrew Cellar is a symlink: #{HOMEBREW_CELLAR}
                      which resolves to: #{HOMEBREW_CELLAR.realpath}

      The recommended Homebrew installations are either:
      (A) Have Cellar be a real directory inside of your HOMEBREW_PREFIX
      (B) Symlink "bin/brew" into your prefix, but don't symlink "Cellar".

      Older installations of Homebrew may have created a symlinked Cellar, but this can
      cause problems when two formula install to locations that are mapped on top of each
      other during the linking step.
    EOS
  end
end

def check_for_multiple_volumes
  return unless HOMEBREW_CELLAR.exist?
  volumes = Volumes.new

  # Find the volumes for the TMP folder & HOMEBREW_CELLAR
  real_cellar = HOMEBREW_CELLAR.realpath

  tmp_prefix = ENV['HOMEBREW_TEMP'] || '/tmp'
  tmp = Pathname.new `/usr/bin/mktemp -d #{tmp_prefix}/homebrew-brew-doctor-XXXX`.strip
  real_temp = tmp.realpath.parent

  where_cellar = volumes.which real_cellar
  where_temp = volumes.which real_temp

  Dir.delete tmp

  unless where_cellar == where_temp then <<-EOS.undent
    Your Cellar and TEMP directories are on different volumes.
    OS X won't move relative symlinks across volumes unless the target file already
    exists. Brews known to be affected by this are Git and Narwhal.

    You should set the "HOMEBREW_TEMP" environmental variable to a suitable
    directory on the same volume as your Cellar.
    EOS
  end
end

def check_for_git
  unless which "git" then <<-EOS.undent
    Git could not be found in your PATH.
    Homebrew uses Git for several internal functions, and some formulae use Git
    checkouts instead of stable tarballs. You may want to install Git:
      brew install git
    EOS
  end
end

def check_git_newline_settings
  return unless which "git"

  autocrlf = `git config --get core.autocrlf`.chomp
  safecrlf = `git config --get core.safecrlf`.chomp

  if autocrlf == 'input' and safecrlf == 'true' then <<-EOS.undent
    Suspicious Git newline settings found.

    The detected Git newline settings can cause checkout problems:
      core.autocrlf = #{autocrlf}
      core.safecrlf = #{safecrlf}

    If you are not routinely dealing with Windows-based projects,
    consider removing these settings.
    EOS
  end
end

def check_for_git_origin
  return unless which "git"

  HOMEBREW_REPOSITORY.cd do
    if `git config --get remote.origin.url`.chomp.empty? then <<-EOS.undent
      Missing git origin remote.

      Without a correctly configured origin, Homebrew won't update
      properly. You can solve this by adding the Homebrew remote:
        cd #{HOMEBREW_REPOSITORY}
        git add remote origin https://github.com/mxcl/homebrew.git
      EOS
    end
  end
end

def check_the_git_origin
  return unless which "git"
  return if check_for_git_origin

  if MacOS.version == :tiger or MacOS.version == :leopard
    canonical_repo = 'https://github.com/mistydemeo/tigerbrew.git'
    canonical_suffix = /mistydemeo\/tigerbrew(\.git)?$/
  else
    canonical_repo = 'https://github.com/mxcl/homebrew.git'
    canonical_suffix = /mxcl\/homebrew(\.git)?$/
  end

  HOMEBREW_REPOSITORY.cd do
    origin = `git config --get remote.origin.url`.chomp

    unless origin =~ canonical_suffix then <<-EOS.undent
      Suspicious git origin remote found.

      With a non-standard origin, Homebrew won't pull updates from
      the main repository. The current git origin is:
        #{origin}

      Unless you have compelling reasons, consider setting the
      origin remote to point at the main repository, located at:
        #{canonical_repo}
      EOS
    end
  end
end

def check_for_autoconf
  return unless MacOS::Xcode.provides_autotools?

  autoconf = which('autoconf')
  safe_autoconfs = %w[/usr/bin/autoconf /Developer/usr/bin/autoconf]
  unless autoconf.nil? or safe_autoconfs.include? autoconf.to_s then <<-EOS.undent
    An "autoconf" in your path blocks the Xcode-provided version at:
      #{autoconf}

    This custom autoconf may cause some Homebrew formulae to fail to compile.
    EOS
  end
end

def __check_linked_brew f
  links_found = []

  f.prefix.find do |src|
    dst=HOMEBREW_PREFIX+src.relative_path_from(f.prefix)
    next unless dst.symlink?

    dst_points_to = dst.realpath()
    next unless dst_points_to.to_s == src.to_s

    if src.directory?
      Find.prune
    else
      links_found << dst
    end
  end

  return links_found
end

def check_for_linked_keg_only_brews
  require 'formula'

  return unless HOMEBREW_CELLAR.exist?

  warnings = Hash.new

  Formula.each do |f|
    next unless f.keg_only? and f.installed?
    links = __check_linked_brew f
    warnings[f.name] = links unless links.empty?
  end

  unless warnings.empty?
    s = <<-EOS.undent
    Some keg-only formula are linked into the Cellar.
    Linking a keg-only formula, such as gettext, into the cellar with
    `brew link f` will cause other formulae to detect them during the
    `./configure` step. This may cause problems when compiling those
    other formulae.

    Binaries provided by keg-only formulae may override system binaries
    with other strange results.

    You may wish to `brew unlink` these brews:

    EOS
    warnings.keys.each{ |f| s << "    #{f}\n" }
    s
  end
end

def check_for_MACOSX_DEPLOYMENT_TARGET
  target_var = ENV['MACOSX_DEPLOYMENT_TARGET']
  if target_var and target_var != MACOS_VERSION.to_s then <<-EOS.undent
    MACOSX_DEPLOYMENT_TARGET was set to #{target_var}
    This is used by Fink, but having it set to a value different from the
    current system version (#{MACOS_VERSION}) can cause problems, compiling
    Git for instance, and should probably be removed.
    EOS
  end
end

def check_for_other_frameworks
  # Other frameworks that are known to cause problems when present
  %w{Mono.framework expat.framework libexpat.framework}.
    map{ |frmwrk| "/Library/Frameworks/#{frmwrk}" }.
    select{ |frmwrk| File.exist? frmwrk }.
    map do |frmwrk| <<-EOS.undent
      #{frmwrk} detected
      This can be picked up by CMake's build system and likely cause the build to
      fail. You may need to move this file out of the way to compile CMake.
      EOS
    end.join
end

def check_tmpdir
  tmpdir = ENV['TMPDIR']
  "TMPDIR #{tmpdir.inspect} doesn't exist." unless tmpdir.nil? or File.directory? tmpdir
end

def check_missing_deps
  return unless HOMEBREW_CELLAR.exist?
  s = Set.new
  Homebrew.missing_deps(Formula.installed).each do |_, deps|
    s.merge deps
  end

  if s.length > 0 then <<-EOS.undent
    Some installed formula are missing dependencies.
    You should `brew install` the missing dependencies:

        brew install #{s.to_a.sort * " "}

    Run `brew missing` for more details.
    EOS
  end
end

def check_git_status
  return unless which "git"
  HOMEBREW_REPOSITORY.cd do
    unless `git status -s -- Library/Homebrew/ 2>/dev/null`.chomp.empty?
      <<-EOS.undent_________________________________________________________72
      You have uncommitted modifications to Homebrew
      If this a surprise to you, then you should stash these modifications.
      Stashing returns Homebrew to a pristine state but can be undone
      should you later need to do so for some reason.
          cd #{HOMEBREW_REPOSITORY}/Library && git stash && git clean -f
      EOS
    end
  end
end

def check_for_leopard_ssl
  if MacOS.version == :leopard and not ENV['GIT_SSL_NO_VERIFY']
    <<-EOS.undent
      The version of libcurl provided with Mac OS X Leopard has outdated
      SSL certificates.

      This can cause problems when running Homebrew commands that use Git to
      fetch over HTTPS, e.g. `brew update` or installing formulae that perform
      Git checkouts.

      You can force Git to ignore these errors by setting GIT_SSL_NO_VERIFY.
        export GIT_SSL_NO_VERIFY=1
    EOS
  end
end

def check_git_version
  # see https://github.com/blog/642-smart-http-support
  return unless which "git"
  `git --version`.chomp =~ /git version (\d)\.(\d)\.(\d)/

  if $2.to_i < 6 or $2.to_i == 6 and $3.to_i < 6 then <<-EOS.undent
    An outdated version of Git was detected in your PATH.
    Git 1.6.6 or newer is required to perform checkouts over HTTP from GitHub.
    Please upgrade: brew upgrade git
    EOS
  end
end

def check_for_enthought_python
  if which "enpkg" then <<-EOS.undent
    Enthought Python was found in your PATH.
    This can cause build problems, as this software installs its own
    copies of iconv and libxml2 into directories that are picked up by
    other build systems.
    EOS
  end
end

def check_for_bad_python_symlink
  return unless which "python"
  # Indeed Python -V outputs to stderr (WTF?)
  `python -V 2>&1` =~ /Python (\d+)\./
  # This won't be the right warning if we matched nothing at all
  return if $1.nil?
  unless $1 == "2" then <<-EOS.undent
    python is symlinked to python#$1
    This will confuse build scripts and in general lead to subtle breakage.
    EOS
  end
end

def check_for_pydistutils_cfg_in_home
  if File.exist? ENV['HOME']+'/.pydistutils.cfg' then <<-EOS.undent
    A .pydistutils.cfg file was found in $HOME, which may cause Python
    builds to fail. See:
      http://bugs.python.org/issue6138
      http://bugs.python.org/issue4655
    EOS
  end
end

def check_for_outdated_homebrew
  return unless which 'git'
  HOMEBREW_REPOSITORY.cd do
    if File.directory? ".git"
      local = `git rev-parse -q --verify refs/remotes/origin/master`.chomp
      remote = /^([a-f0-9]{40})/.match(`git ls-remote origin refs/heads/master 2>/dev/null`)
      if remote.nil? || local == remote[0]
        return
      end
    end

    timestamp = if File.directory? ".git"
      `git log -1 --format="%ct" HEAD`.to_i
    else
      (HOMEBREW_REPOSITORY/"Library").mtime.to_i
    end

    if Time.now.to_i - timestamp > 60 * 60 * 24 then <<-EOS.undent
      Your Homebrew is outdated
      You haven't updated for at least 24 hours, this is a long time in brewland!
      EOS
    end
  end
end

def check_for_unlinked_but_not_keg_only
  return unless HOMEBREW_CELLAR.exist?
  unlinked = HOMEBREW_CELLAR.children.reject do |rack|
    if not rack.directory?
      true
    elsif not (HOMEBREW_REPOSITORY/"Library/LinkedKegs"/rack.basename).directory?
      Formula.factory(rack.basename).keg_only? rescue nil
    else
      true
    end
  end.map{ |pn| pn.basename }

  # NOTE very old kegs will be linked without the LinkedKegs symlink
  # this will trigger this warning but it's wrong, we could detect that though
  # but I don't feel like writing the code.

  if not unlinked.empty? then <<-EOS.undent
    You have unlinked kegs in your Cellar
    Leaving kegs unlinked can lead to build-trouble and cause brews that depend on
    those kegs to fail to run properly once built. Run `brew link` on these:

        #{unlinked * "\n        "}
    EOS
  end
end

def check_os_version
  if MACOS_FULL_VERSION =~ /^10\.6(\.|$)/
    unless (MACOS_FULL_VERSION == "10.6.8")
      return <<-EOS.undent
        Please update Snow Leopard.
        10.6.8 is the supported version of Snow Leopard.
        You are still running #{MACOS_FULL_VERSION}.
      EOS
    end
  elsif MACOS_FULL_VERSION =~ /^10\.5(\.|$)/
    unless (MACOS_FULL_VERSION == "10.5.8")
      return <<-EOS.undent
        Please update Leopard.
        10.5.8 is the supported version of Leopard.
        You are still running #{MACOS_FULL_VERSION}.
      EOS
    end
  end
end

  def check_xcode_license_approved
    return if MacOS::Xcode.bad_xcode_select_path?
    # If the user installs Xcode-only, they have to approve the
    # license or no "xc*" tool will work.
    <<-EOS.undent if `/usr/bin/xcrun clang 2>&1` =~ /license/ and not $?.success?
    You have not agreed to the Xcode license.
    Builds will fail! Agree to the license by opening Xcode.app or running:
        xcodebuild -license
    EOS
  end

  def check_for_latest_xquartz
    quartz = MacOS::XQuartz.version
    return unless quartz
    return if MacOS::XQuartz.provided_by_apple?

    quartz = Version.new(quartz)
    latest = Version.new(MacOS::XQuartz.latest_version)

    return if quartz >= latest

    <<-EOS.undent
      Your XQuartz (#{quartz}) is outdated
      Please install XQuartz #{latest}.
    EOS
  end
end # end class Checks

module Homebrew extend self
  def doctor
    checks = Checks.new

    if ARGV.include? '--list-checks'
      checks.methods.select { |m| m =~ /^check_/ }.sort.each { |m| puts m }
      exit
    end

    inject_dump_stats(checks) if ARGV.switch? 'D'

    methods = if ARGV.named.empty?
      # put slowest methods last
      checks.methods.sort << "check_for_linked_keg_only_brews" << "check_for_outdated_homebrew"
    else
      ARGV.named
    end.select{ |method| method =~ /^check_/ }.reverse.uniq.reverse

    methods.each do |method|
      out = checks.send(method)
      unless out.nil? or out.empty?
        lines = out.to_s.split('\n')
        opoo lines.shift
        Homebrew.failed = true
        puts lines
      end
    end

    puts "Your system is raring to brew." unless Homebrew.failed?
  end

  def inject_dump_stats checks
    class << checks
      alias_method :oldsend, :send
      def send method
        time = Time.now
        oldsend(method)
      ensure
        $times[method] = Time.now - time
      end
    end
    $times = {}
    at_exit {
      puts $times.sort_by{|k, v| v }.map{|k, v| "#{k}: #{v}"}
    }
  end
end
