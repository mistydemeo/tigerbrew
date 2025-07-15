class Subversion < Formula
  desc "Version control system designed to be a better CVS"
  homepage "https://subversion.apache.org/"
  url "https://dlcdn.apache.org/subversion/subversion-1.14.5.tar.bz2"
  mirror "https://archive.apache.org/dist/subversion/subversion-1.14.5.tar.bz2"
  sha256 "e78a29e7766b8b7b354497d08f71a55641abc53675ce1875584781aae35644a1"

  bottle do
  end

  deprecated_option "java" => "with-java"
  deprecated_option "perl" => "with-perl"
  deprecated_option "ruby" => "with-ruby"

  option :universal
  option "with-java", "Build Java bindings"
  option "with-perl", "Build Perl bindings"
  option "with-ruby", "Build Ruby bindings"
  option "with-gpg-agent", "Build with support for GPG Agent"

  resource "serf" do
    url "https://www.apache.org/dist/serf/serf-1.3.10.tar.bz2", :using => :curl
    sha256 "be81ef08baa2516ecda76a77adf7def7bc3227eeb578b9a33b45f7b41dc064e6"
  end

  depends_on "lz4"
  depends_on "zlib"

  # use Tigerbrew's version instead of the old one in X11
  depends_on :expat
  depends_on :ld64

  depends_on "pkg-config" => :build
  if MacOS.version > :leopard
    depends_on :apr => :build
  else
    depends_on "apr"
    depends_on "apr-util"
  end

  # Always build against Homebrew versions instead of system versions for consistency.
  depends_on "sqlite"
  depends_on :python => :optional

  # Bindings require swig
  depends_on "swig" if build.with?("perl") || build.with?("python") || build.with?("ruby")

  # For Serf
  depends_on "scons" => :build
  depends_on "openssl3"

  # Other optional dependencies
  depends_on "gpg-agent" => :optional
  depends_on :java => :optional

  if build.with?("perl") || build.with?("ruby")
    # If building bindings, allow non-system interpreters
    # Currently the serf -> scons dependency forces stdenv, so this isn't
    # strictly necessary
    env :userpaths

    # When building Perl or Ruby bindings, need to use a compiler that
    # recognizes GCC-style switches, since that's what the system languages
    # were compiled against.
    fails_with :clang do
      build 318
      cause "core.c:1: error: bad value (native) for -march= switch"
    end
  end

  def install
    serf_prefix = libexec+"serf"

    resource("serf").stage do
      # SConstruct merges in gssapi linkflags using scons's MergeFlags,
      # but that discards duplicate values - including the duplicate
      # values we want, like multiple -arch values for a universal build.
      # Passing 0 as the `unique` kwarg turns this behaviour off.
      inreplace "SConstruct", "unique=1", "unique=0"

      ENV.universal_binary if build.universal?
      # scons ignores our compiler and flags unless explicitly passed
      args = %W[PREFIX=#{serf_prefix} GSSAPI=/usr CC=#{ENV.cc}
                CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}
                OPENSSL=#{Formula["openssl3"].opt_prefix}]

      if MacOS.version <= :leopard || !MacOS::CLT.installed?
        args << "APR=#{Formula['apr'].opt_prefix}"
        args << "APU=#{Formula['apr-util'].opt_prefix}"
      end

      scons *args
      scons "install"
    end

    if build.include? "unicode-path"
      raise <<-EOS.undent
        The --unicode-path patch is not supported on Subversion 1.8.

        Upgrading from a 1.7 version built with this patch is not supported.

        You should stay on 1.7, install 1.7 from homebrew-versions, or
          brew rm subversion && brew install subversion
        to build a new version of 1.8 without this patch.
      EOS
    end

    if build.with? "java"
      # Java support doesn't build correctly in parallel:
      # https://github.com/Homebrew/homebrew/issues/20415
      ENV.deparallelize

      unless build.universal?
        opoo "A non-Universal Java build was requested."
        puts <<-EOS.undent
        To use Java bindings with various Java IDEs, you might need a universal build:
          `brew install subversion --universal --java`
        EOS
      end
    end

    ENV.universal_binary if build.universal?

    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-zlib=#{Formula["zlib"].opt_prefix}",
            "--with-sqlite=#{Formula["sqlite"].opt_prefix}",
            "--with-serf=#{serf_prefix}",
            "--disable-mod-activation",
            "--disable-nls",
            "--without-apache-libexecdir",
            "--without-berkeley-db",
            "--with-utf8proc=internal"]

    args << "--enable-javahl" << "--without-jikes" if build.with? "java"
    args << "--without-gpg-agent" if build.without? "gpg-agent"

    if MacOS.version > :leopard && MacOS::CLT.installed?
      args << "--with-apr=/usr"
      args << "--with-apr-util=/usr"
    else
      args << "--with-apr=#{Formula["apr"].opt_prefix}"
      args << "--with-apr-util=#{Formula["apr-util"].opt_prefix}"
      args << "--with-apxs=no"
    end

    if build.with? "ruby"
      args << "--with-ruby-sitedir=#{lib}/ruby"
      # Peg to system Ruby
      args << "RUBY=/usr/bin/ruby"
    end

    # If Python is built universally, then extensions built with that Python
    # are too. This default behaviour is not desired when building an extension
    # for a single architecture.
    if build.with?("python") && (which "python").universal? && !build.universal?
      ENV["ARCHFLAGS"] = "-arch #{MacOS.preferred_arch}"
    end

    # The system Python is built with llvm-gcc, so we override this
    # variable to prevent failures due to incompatible CFLAGS
    ENV["ac_cv_python_compile"] = ENV.cc

    inreplace "Makefile.in",
              "toolsdir = @bindir@/svn-tools",
              "toolsdir = @libexecdir@/svn-tools"

    system "./configure", *args
    system "make"
    system "make", "install"
    bash_completion.install "tools/client-side/bash_completion" => "subversion"

    system "make", "tools"
    system "make", "install-tools"

    if build.with? "python"
      system "make", "swig-py"
      system "make", "install-swig-py"
      (lib/"python2.7/site-packages").install_symlink Dir["#{lib}/svn-python/*"]
    end

    if build.with? "perl"
      # In theory SWIG can be built in parallel, in practice...
      ENV.deparallelize
      # Remove hard-coded ppc target, add appropriate ones
      if build.universal?
        arches = Hardware::CPU.universal_archs.as_arch_flags
      elsif MacOS.version <= :leopard
        arches = "-arch #{Hardware::CPU.arch_32_bit}"
      else
        arches = "-arch #{Hardware::CPU.arch_64_bit}"
      end

      perl_core = Pathname.new(`perl -MConfig -e 'print $Config{archlib}'`)+"CORE"
      unless perl_core.exist?
        onoe "perl CORE directory does not exist in '#{perl_core}'"
      end

      inreplace "Makefile" do |s|
        s.change_make_var! "SWIG_PL_INCLUDES",
          "$(SWIG_INCLUDES) #{arches} -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -I/usr/local/include -I#{perl_core}"
      end
      system "make", "swig-pl"
      system "make", "install-swig-pl", "DESTDIR=#{prefix}"

      # Some of the libraries get installed into the wrong place, they end up having the
      # prefix in the directory name twice.

      lib.install Dir["#{prefix}/#{lib}/*"]
    end

    if build.with? "java"
      system "make", "javahl"
      system "make", "install-javahl"
    end

    if build.with? "ruby"
      # Peg to system Ruby
      system "make", "swig-rb", "EXTRA_SWIG_LDFLAGS=-L/usr/lib"
      system "make", "install-swig-rb"
    end
  end

  def caveats
    s = <<-EOS.undent
      svntools have been installed to:
        #{opt_libexec}
    EOS

    if build.with? "perl"
      s += <<-EOS.undent

        The perl bindings are located in various subdirectories of:
          #{prefix}/Library/Perl
      EOS
    end

    if build.with? "ruby"
      s += <<-EOS.undent

        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby
      EOS
    end

    if build.with? "java"
      s += <<-EOS.undent

        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{HOMEBREW_PREFIX}/lib/libsvnjavahl-1.dylib /Library/Java/Extensions/libsvnjavahl-1.dylib
      EOS
    end

    s
  end

  test do
    system "#{bin}/svnadmin", "create", "test"
    system "#{bin}/svnadmin", "verify", "test"
  end
end
