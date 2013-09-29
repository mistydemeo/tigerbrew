require 'formula'

class Git < Formula
  homepage 'http://git-scm.com'
  url 'http://git-core.googlecode.com/files/git-1.8.4.tar.gz'
  sha1 '2a361a2d185b8bc604f7f2ce2f502d0dea9d3279'
  head 'https://github.com/git/git.git'

  bottle do
    sha1 'c752e68f6c39a567adfa43eea9f6b74caaf35bcf' => :mountain_lion
    sha1 'ca4b4ce0455636400ad70e413c179fe4e3329288' => :lion
    sha1 'c5a3559d59c7d9cd608559771ece10743a340c32' => :snow_leopard
  end

  option 'with-blk-sha1', 'Compile with the block-optimized SHA1 implementation'
  option 'without-completions', 'Disable bash/zsh completions from "contrib" directory'
  option 'with-brewed-openssl', "Build with Homebrew OpenSSL instead of the system version" if MacOS.version < :leopard
  option 'with-brewed-curl', "Use Homebrew's version of cURL library" if MacOS.version < :snow_leopard

  if MacOS.version == :tiger
    # system tar has odd permissions errors
    depends_on 'gnu-tar' => :build
    # Tiger's ld produces bad install-names for a keg-only curl
    depends_on 'ld64' => :build
    depends_on 'cctools' => :build
  end

  if MacOS.version < :snow_leopard
    depends_on 'curl' if MacOS.version < :snow_leopard
  else
    depends_on 'curl' => 'with-darwinssl' if build.with? 'brewed-curl'
  end
  depends_on :expat
  depends_on 'gettext' => :optional
  depends_on 'openssl' if MacOS.version < :leopard || build.with?('brewed-openssl')
  depends_on 'pcre' if build.include? 'with-pcre'
  depends_on :python

  resource 'man' do
    url 'http://git-core.googlecode.com/files/git-manpages-1.8.4.tar.gz'
    sha1 '8c67a7bc442d6191bc17633c7f2846c71bda71cf'
  end

  resource 'html' do
    url 'http://git-core.googlecode.com/files/git-htmldocs-1.8.4.tar.gz'
    sha1 'f130398eb623c913497ef51a6e61d916fe7e31c8'
  end

  def patches
    # ld64 understands -rpath but rejects it on Tiger
    'https://trac.macports.org/export/106975/trunk/dports/devel/git-core/files/patch-Makefile.diff'
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
    ENV['PYTHON_PATH'] = python.binary if python
    ENV['PERL_PATH'] = which 'perl'
    ENV['CURLDIR'] = Formula.factory('curl').opt_prefix if MacOS.version < :snow_leopard
    ENV['NO_APPLE_COMMON_CRYPTO'] = '1' if MacOS.version < :leopard

    unless quiet_system ENV['PERL_PATH'], '-e', 'use ExtUtils::MakeMaker'
      ENV['NO_PERL_MAKEMAKER'] = '1'
    end

    ENV['BLK_SHA1'] = '1' if build.with? 'blk-sha1'

    if build.with? 'pcre'
      ENV['USE_LIBPCRE'] = '1'
      ENV['LIBPCREDIR'] = Formula.factory('pcre').opt_prefix
    end

    ENV['LD'] = Formula.factory('ld64').opt_prefix/'bin/ld'
    ENV['NO_GETTEXT'] = '1' unless build.with? 'gettext'

    system "make", "prefix=#{prefix}",
                   "sysconfdir=#{etc}",
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
    man.install resource('man')
    (share+'doc/git-doc').install resource('html')
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
      assert_equal 'bin/brew', `#{bin}/git ls-files -- bin`.strip
    end
  end
end
