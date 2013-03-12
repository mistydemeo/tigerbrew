require 'formula'

class GitManuals < Formula
  url 'http://git-core.googlecode.com/files/git-manpages-1.8.1.5.tar.gz'
  sha1 '7f211a2f8fe36180373a20b32eb930018883bfd1'
end

class GitHtmldocs < Formula
  url 'http://git-core.googlecode.com/files/git-htmldocs-1.8.1.5.tar.gz'
  sha1 '84d832fc70a053e97ce336c4a0af0371461e469f'
end

class Git < Formula
  homepage 'http://git-scm.com'
  url 'http://git-core.googlecode.com/files/git-1.8.1.5.tar.gz'
  sha1 '3349a15de7c5501715bda9b68301d0406272f8e0'

  head 'https://github.com/git/git.git'

  if MacOS.version == :tiger
    # system tar has odd permissions errors
    depends_on 'gnu-tar' => :build
    # Tiger's ld produces bad install-names for a keg-only curl
    depends_on 'ld64' => :build
    depends_on 'cctools' => :build
  end

  depends_on 'curl' if MacOS.version < :snow_leopard
  depends_on 'pcre' if build.include? 'with-pcre'

  option 'with-blk-sha1', 'Compile with the block-optimized SHA1 implementation'
  option 'without-completions', 'Disable bash/zsh completions from "contrib" directory'

  depends_on 'pcre' => :optional

  def patches
    # ld64 understands -rpath but rejects it on Tiger
    'https://trac.macports.org/export/103986/trunk/dports/devel/git-core/files/patch-Makefile.diff'
  end if MacOS.version == :tiger

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

    ENV['BLK_SHA1'] = '1' if build.with? 'blk-sha1'

    if build.with? 'pcre'
      ENV['USE_LIBPCRE'] = '1'
      ENV['LIBPCREDIR'] = HOMEBREW_PREFIX
    end

    ENV['LD'] = Formula.factory('ld64').opt_prefix/'bin/ld'

    system "make", "prefix=#{prefix}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "install"

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

    unless build.without? 'completions'
      # install the completion script first because it is inside 'contrib'
      bash_completion.install 'contrib/completion/git-completion.bash'
      bash_completion.install 'contrib/completion/git-prompt.sh'

      zsh_completion.install 'contrib/completion/git-completion.zsh' => '_git'
      cp "#{bash_completion}/git-completion.bash", zsh_completion
    end

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
