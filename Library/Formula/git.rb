class Git < Formula
  homepage "https://git-scm.com"
  url "https://www.kernel.org/pub/software/scm/git/git-2.4.0.tar.xz"
  sha256 "b33438dd94659958a74850aacae4a2b3a626baec36d7f29c266130b08045bb24"

  head "https://github.com/git/git.git", :shallow => false

  bottle do
    sha1 "7f994371e942492bae4a3a29fea60131e1f09413" => :tiger_altivec
    sha1 "720f81944844006029603896a1268c2de9743715" => :leopard_g3
    sha1 "a83e507778eb4d522b456014fbe19d0d4311ddeb" => :leopard_altivec
  end

  resource "man" do
    url "https://www.kernel.org/pub/software/scm/git/git-manpages-2.4.0.tar.xz"
    sha256 "b616dc6aa02dcac312e6aeae7af148913f76e1f851ba03ba340b4d2db316ecc7"
  end

  resource "html" do
    url "https://www.kernel.org/pub/software/scm/git/git-htmldocs-2.4.0.tar.xz"
    sha256 "70ee1fdb70507c74832ac021e8940c8249d9b69f2b86aeaf0888ae41772e93a7"
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
      ].uniq.map { |p|
        "#{p}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
      }.join(":")
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

    system "make", "prefix=#{prefix}",
                   "sysconfdir=#{etc}",
                   "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "LDFLAGS=#{ENV.ldflags}",
                   "install"

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
