class Git < Formula
  desc "Distributed revision control system"
  homepage "https://git-scm.com"
  url "https://www.kernel.org/pub/software/scm/git/git-2.5.2.tar.xz"
  sha256 "4b4760a90ede51accee703bd6815f1f79afef68670acdcf3ea31dcc846a40c9b"

  head "https://github.com/git/git.git", :shallow => false

  bottle do
    sha256 "6331cfd02518ab7b56dc9decda5c0b8265c743b32a27c6b3f0a69035557ccf8f" => :tiger_altivec
    sha256 "a95dcac37da540b1b521d50f6fb540f685fbf12c3c32fd63dfdd4426bd562648" => :leopard_g3
    sha256 "06265dc5128e93306b683e4aeb67af6672602bd7c04709b7b879a74b971f5f16" => :leopard_altivec
  end

  resource "man" do
    url "https://www.kernel.org/pub/software/scm/git/git-manpages-2.5.2.tar.xz"
    sha256 "76512caa7044710f9954079828218cd94ab17da34effd3bdd9db2434d18720c2"
  end

  resource "html" do
    url "https://www.kernel.org/pub/software/scm/git/git-htmldocs-2.5.2.tar.xz"
    sha256 "87e416455a293552c2bab46fb3ec75424e2143e6f98f5ce7bcb6d4e50c4020eb"
  end

  option "with-blk-sha1", "Compile with the block-optimized SHA1 implementation"
  option "without-completions", "Disable bash/zsh completions from 'contrib' directory"
  option "with-brewed-openssl", "Build with Homebrew OpenSSL instead of the system version" if MacOS.version > :snow_leopard
  option "with-brewed-curl", "Use Homebrew's version of cURL library" if MacOS.version > :snow_leopard
  option "with-brewed-svn", "Use Homebrew's version of SVN"
  option "with-persistent-https", "Build git-remote-persistent-https from 'contrib' directory"

  if MacOS.version == :tiger
    # system tar has odd permissions errors
    depends_on "gnu-tar" => :build
    # Tiger's ld produces bad install-names for a keg-only curl
    depends_on "ld64" => :build
    depends_on "cctools" => :build
  end

  depends_on :expat
  depends_on "pcre" => :optional
  depends_on "gettext" => :optional
  depends_on "openssl" if MacOS.version < :snow_leopard || build.with?("brewed-openssl")
  depends_on "curl" if MacOS.version < :snow_leopard || build.with?("brewed-curl")
  depends_on "go" => :build if build.with? "persistent-https"
  # Trigger an install of swig before subversion, as the "swig" doesn't get pulled in otherwise
  # See https://github.com/Homebrew/homebrew/issues/34554
  if build.with? "brewed-svn"
    depends_on "swig"
    depends_on "subversion" => "with-perl"
  end

  # ld64 understands -rpath but rejects it on Tiger
  patch :p1 do
    url "https://trac.macports.org/export/106975/trunk/dports/devel/git-core/files/patch-Makefile.diff"
    sha1 "f033e5b78ecbfcc14b7994f98a74dfdbe607eea0"
  end if MacOS.version < :leopard

  def install
    # git's index-pack will segfault unless compiled without optimization
    # with the Tigerbrew apple-gcc42 on Tiger
    if MacOS.version < :leopard && ENV.compiler == :gcc
      ENV.no_optimization
    end

    if MacOS.version == :tiger
      tar = Formula['gnu-tar']
      tab = Tab.for_keg tar.installed_prefix
      tar_name = tab.used_options.include?('--default-names') ? tar.bin/'tar' : tar.bin/'gtar'
      inreplace 'Makefile' do |s|
        s.change_make_var! 'TAR', tar_name.to_s
      end
    end

    # If these things are installed, tell Git build system to not use them
    ENV["NO_FINK"] = "1"
    ENV["NO_DARWIN_PORTS"] = "1"
    ENV["V"] = "1" # build verbosely
    ENV["NO_R_TO_GCC_LINKER"] = "1" # pass arguments to LD correctly
    ENV["PYTHON_PATH"] = which "python"
    ENV["PERL_PATH"] = which "perl"
    ENV["CURLDIR"] = Formula["curl"].opt_prefix if MacOS.version < :snow_leopard
    ENV["NO_APPLE_COMMON_CRYPTO"] = "1" if MacOS.version < :leopard

    perl_version = /\d\.\d+/.match(`perl --version`)

    if build.with? "brewed-svn"
      ENV["PERLLIB_EXTRA"] = "#{Formula["subversion"].opt_prefix}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
    elsif MacOS.version >= :mavericks
      ENV["PERLLIB_EXTRA"] = %W[
        #{MacOS.active_developer_dir}
        /Library/Developer/CommandLineTools
        /Applications/Xcode.app/Contents/Developer
      ].uniq.map do |p|
        "#{p}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
      end.join(":")
    end

    unless quiet_system ENV["PERL_PATH"], "-e", "use ExtUtils::MakeMaker"
      ENV["NO_PERL_MAKEMAKER"] = "1"
    end

    ENV["BLK_SHA1"] = "1" if build.with? "blk-sha1"

    if build.with? "pcre"
      ENV["USE_LIBPCRE"] = "1"
      ENV["LIBPCREDIR"] = Formula["pcre"].opt_prefix
    end

    ENV["NO_GETTEXT"] = "1" if build.without? "gettext"

    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      CC=#{ENV.cc}
      CFLAGS=#{ENV.cflags}
      LDFLAGS=#{ENV.ldflags}
    ]
    args << "NO_OPENSSL=1" << "APPLE_COMMON_CRYPTO=1" if build.without? "brewed-openssl" unless MacOS.version < :snow_leopard

    system "make", "install", *args

    # Install the OS X keychain credential helper
    cd "contrib/credential/osxkeychain" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-credential-osxkeychain"
      system "make", "clean"
    end

    # Install git-subtree
    cd "contrib/subtree" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-subtree"
    end

    if build.with? "persistent-https"
      cd "contrib/persistent-https" do
        system "make"
        bin.install "git-remote-persistent-http",
                    "git-remote-persistent-https",
                    "git-remote-persistent-https--proxy"
      end
    end

    if build.with? "completions"
      # install the completion script first because it is inside "contrib"
      bash_completion.install "contrib/completion/git-completion.bash"
      bash_completion.install "contrib/completion/git-prompt.sh"

      zsh_completion.install "contrib/completion/git-completion.zsh" => "_git"
      cp "#{bash_completion}/git-completion.bash", zsh_completion
    end

    (share+"git-core").install "contrib"

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    man.install resource("man")
    (share+"doc/git-doc").install resource("html")

    # Make html docs world-readable
    chmod 0644, Dir["#{share}/doc/git-doc/**/*.{html,txt}"]
    chmod 0755, Dir["#{share}/doc/git-doc/{RelNotes,howto,technical}"]

    # To avoid this feature hooking into the system OpenSSL, remove it.
    # If you need it, install git --with-brewed-openssl.
    rm "#{libexec}/git-core/git-imap-send" if build.without? "brewed-openssl"
  end

  def caveats; <<-EOS.undent
    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain

    The "contrib" directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal "bin/brew", `#{bin}/git ls-files -- bin`.strip
    end
  end
end
