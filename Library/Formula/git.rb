require 'formula'

class GitManuals < Formula
  url 'http://git-core.googlecode.com/files/git-manpages-1.8.1.1.tar.gz'
  sha1 '5089613a434ba09c94f6694d546c246838377760'
end

class GitHtmldocs < Formula
  url 'http://git-core.googlecode.com/files/git-htmldocs-1.8.1.1.tar.gz'
  sha1 '952e0950d40bb141357be88a63f4cbb58258a4f5'
end

class Git < Formula
  homepage 'http://git-scm.com'
  url 'http://git-core.googlecode.com/files/git-1.8.1.1.tar.gz'
  sha1 '44b90aab937b0e0dbb0661eb5ec4ca6182e60854'

  head 'https://github.com/git/git.git'

  # system tar has odd permissions errors
  depends_on 'gnu-tar' => :build if MacOS.version == :tiger
  depends_on 'curl' if MacOS.version < :snow_leopard
  depends_on 'pcre' if build.include? 'with-pcre'

  option 'with-blk-sha1', 'Compile with the block-optimized SHA1 implementation'
  option 'with-pcre', 'Compile with the PCRE library'

  # git tries to use the -rpath linker command, which isn't valid on OS X
  def patches
    "https://trac.macports.org/export/100394/trunk/dports/devel/git-core/files/patch-Makefile.diff"
  end

  def install
    # git's index-pack will segfault unless compiled without optimization
    ENV.no_optimization if MacOS.version == :tiger

    if MacOS.version == :tiger
      tar = Formula.factory('gnu-tar')
      tab = Tab.for_keg tar.installed_prefix
      tar_name = tab.used_options.include?('--default-names') ? tar.bin/'tar' : tar.bin/'gtar'
      inreplace 'Makefile' do |s|
        s.change_make_var! 'TAR', tar_name.to_s
      end
    end

    # If these things are installed, tell Git build system to not use them
    ENV['NO_FINK'] = '1'
    ENV['NO_DARWIN_PORTS'] = '1'
    ENV['V'] = '1' # build verbosely
    ENV['NO_R_TO_GCC_LINKER'] = '1' # pass arguments to LD correctly
    ENV['NO_GETTEXT'] = '1'
    ENV['PERL_PATH'] = which 'perl' # workaround for users of perlbrew
    ENV['PYTHON_PATH'] = which 'python' # python can be brewed or unbrewed
    ENV['CURLDIR'] = Formula.factory('curl').opt_prefix if MacOS.version < :snow_leopard

    # Clean XCode 4.x installs don't include Perl MakeMaker
    ENV['NO_PERL_MAKEMAKER'] = '1' if MacOS.version >= :lion

    ENV['BLK_SHA1'] = '1' if build.include? 'with-blk-sha1'

    if build.include? 'with-pcre'
      ENV['USE_LIBPCRE'] = '1'
      ENV['LIBPCREDIR'] = HOMEBREW_PREFIX
    end

    system "make", "prefix=#{prefix}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "install"


    # the current linker options result in linking against curl at the wrong path
    # TODO build and use a new ld which should avoid this problem
    system "install_name_tool", libexec/"git-core/git-remote-https",
      "-change", "#{HOMEBREW_PREFIX}/lib/libcurl.4.dylib",
      Formula.factory('curl').opt_prefix/"lib/libcurl.4.dylib"

    # Install the OS X keychain credential helper
    cd 'contrib/credential/osxkeychain' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-credential-osxkeychain'
      system "make", "clean"
    end

    # Install git-subtree
    cd 'contrib/subtree' do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install 'git-subtree'
    end

    # install the completion script first because it is inside 'contrib'
    (prefix+'etc/bash_completion.d').install 'contrib/completion/git-completion.bash'
    (prefix+'etc/bash_completion.d').install 'contrib/completion/git-prompt.sh'
    (share+'git-core').install 'contrib'

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    GitManuals.new.brew { man.install Dir['*'] }
    GitHtmldocs.new.brew { (share+'doc/git-doc').install Dir['*'] }
  end

  def caveats; <<-EOS.undent
    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain

    The 'contrib' directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      `#{bin}/git ls-files -- bin`.chomp == 'bin/brew'
    end
  end
end
