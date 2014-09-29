require 'formula'

class Subversion < Formula
  homepage 'https://subversion.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=subversion/subversion-1.8.10.tar.bz2'
  mirror 'http://archive.apache.org/dist/subversion/subversion-1.8.10.tar.bz2'
  sha1 'd6896d94bb53c1b4c6e9c5bb1a5c466477b19b2b'
  revision 1

  bottle do
    sha1 "83f7b25af964b475ad420e3ba61ea9fdf0c2f573" => :tiger_g3
    sha1 "903909986db0fe483e9a727aa04596500cdaf930" => :tiger_altivec
    sha1 "aa3adab587138a417dc8e5fa51e55580b7ebe81c" => :leopard_g3
    sha1 "0e2b4787dd540ae537b60a6e03bf4535b5a8cff0" => :leopard_altivec
  end

  option :universal
  option 'java', 'Build Java bindings'
  option 'perl', 'Build Perl bindings'
  option 'ruby', 'Build Ruby bindings'

  resource 'serf' do
    url 'https://serf.googlecode.com/svn/src_releases/serf-1.3.7.tar.bz2', :using => :curl
    sha1 'db9ae339dba10a2b47f9bdacf30a58fd8e36683a'
  end

  # use Tigerbrew's version instead of the old one in X11
  depends_on :expat
  # Tiger's are too old
  if MacOS.version < :leopard
    depends_on "homebrew/apache/apr"
    depends_on "homebrew/apache/apr-util"
  end

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  # Always build against Homebrew versions instead of system versions for consistency.
  depends_on 'sqlite'
  depends_on :python => :optional

  # Bindings require swig
  depends_on 'swig' if build.include? 'perl' or build.with? 'python' or build.include? 'ruby'

  # For Serf
  depends_on :ld64
  depends_on 'scons' => :build
  depends_on 'openssl'

  # If building bindings, allow non-system interpreters
  env :userpaths if build.include? 'perl' or build.include? 'ruby'

  # 1. Prevent '-arch ppc' from being pulled in from Perl's $Config{ccflags}
  # 2. Fix #23993 by stripping flags swig can't handle from SWIG_CPPFLAGS
  patch :p0, :DATA

  # When building Perl or Ruby bindings, need to use a compiler that
  # recognizes GCC-style switches, since that's what the system languages
  # were compiled against.
  fails_with :clang do
    build 318
    cause "core.c:1: error: bad value (native) for -march= switch"
  end if build.include? 'perl' or build.include? 'ruby'

  def install
    serf_prefix = libexec+'serf'

    resource('serf').stage do
      # SConstruct merges in gssapi linkflags using scons's MergeFlags,
      # but that discards duplicate values - including the duplicate
      # values we want, like multiple -arch values for a universal build.
      # Passing 0 as the `unique` kwarg turns this behaviour off.
      inreplace 'SConstruct', 'unique=1', 'unique=0'

      ENV.universal_binary if build.universal?
      # scons ignores our compiler and flags unless explicitly passed
      args = %W[PREFIX=#{serf_prefix} GSSAPI=/usr CC=#{ENV.cc}
                CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}
                OPENSSL=#{Formula["openssl"].opt_prefix}]

      if MacOS.version < :leopard
        args << "APR=#{Formula['apr'].opt_bin}/apr-1-config"
        args << "APU=#{Formula['apr-util'].opt_bin}/apu-1-config"
      end

      scons *args
      scons "install"
    end

    if build.include? 'unicode-path'
      raise Homebrew::InstallationError.new(self, <<-EOS.undent
        The --unicode-path patch is not supported on Subversion 1.8.

        Upgrading from a 1.7 version built with this patch is not supported.

        You should stay on 1.7, install 1.7 from homebrew-versions, or
          brew rm subversion && brew install subversion
        to build a new version of 1.8 without this patch.
      EOS
      )
    end

    if build.include? 'java'
      # Java support doesn't build correctly in parallel:
      # https://github.com/Homebrew/homebrew/issues/20415
      ENV.deparallelize

      unless build.universal?
        opoo "A non-Universal Java build was requested."
        puts "To use Java bindings with various Java IDEs, you might need a universal build:"
        puts "  brew install subversion --universal --java"
      end

      if ENV["JAVA_HOME"]
        opoo "JAVA_HOME is set. Try unsetting it if JNI headers cannot be found."
      end
    end

    ENV.universal_binary if build.universal?

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-apr=#{which("apr-1-config").dirname}",
            "--with-zlib=/usr",
            "--with-sqlite=#{Formula["sqlite"].opt_prefix}",
            "--with-serf=#{serf_prefix}",
            "--disable-mod-activation",
            "--disable-nls",
            "--without-apache-libexecdir",
            "--without-berkeley-db"]

    args << "--enable-javahl" << "--without-jikes" if build.include? 'java'

    if build.include? 'ruby'
      args << "--with-ruby-sitedir=#{lib}/ruby"
      # Peg to system Ruby
      args << "RUBY=/usr/bin/ruby"
    end

    # The system Python is built with llvm-gcc, so we override this
    # variable to prevent failures due to incompatible CFLAGS
    ENV['ac_cv_python_compile'] = ENV.cc

    inreplace 'Makefile.in',
              'toolsdir = @bindir@/svn-tools',
              'toolsdir = @libexecdir@/svn-tools'
    # Suggestion by upstream. http://svn.haxx.se/users/archive-2013-09/0188.shtml
    system "./autogen.sh"
    system "./configure", *args
    system "make"
    system "make install"
    bash_completion.install 'tools/client-side/bash_completion' => 'subversion'

    system "make tools"
    system "make install-tools"

    if build.with? 'python'
      system "make swig-py"
      system "make install-swig-py"
    end

    if build.include? 'perl'
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

      perl_core = Pathname.new(`perl -MConfig -e 'print $Config{archlib}'`)+'CORE'
      unless perl_core.exist?
        onoe "perl CORE directory does not exist in '#{perl_core}'"
      end

      inreplace "Makefile" do |s|
        s.change_make_var! "SWIG_PL_INCLUDES",
          "$(SWIG_INCLUDES) #{arches} -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -I/usr/local/include -I#{perl_core}"
      end
      system "make swig-pl"
      system "make", "install-swig-pl", "DESTDIR=#{prefix}"

      # Some of the libraries get installed into the wrong place, they end up having the
      # prefix in the directory name twice.

      lib.install Dir["#{prefix}/#{lib}/*"]
    end

    if build.include? 'java'
      system "make javahl"
      system "make install-javahl"
    end

    if build.include? 'ruby'
      # Peg to system Ruby
      system "make swig-rb EXTRA_SWIG_LDFLAGS=-L/usr/lib"
      system "make install-swig-rb"
    end
  end

  test do
    system "#{bin}/svnadmin", 'create', 'test'
    system "#{bin}/svnadmin", 'verify', 'test'
  end

  def caveats
    s = <<-EOS.undent
      svntools have been installed to:
        #{opt_libexec}
    EOS

    if build.include? 'perl'
      s += <<-EOS.undent

        The perl bindings are located in various subdirectories of:
          #{prefix}/Library/Perl
      EOS
    end

    if build.include? 'ruby'
      s += <<-EOS.undent

        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby
      EOS
    end

    if build.include? 'java'
      s += <<-EOS.undent

        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{HOMEBREW_PREFIX}/lib/libsvnjavahl-1.dylib /Library/Java/Extensions/libsvnjavahl-1.dylib
      EOS
    end

    return s.empty? ? nil : s
  end
end

__END__

Patch 1

--- subversion/bindings/swig/perl/native/Makefile.PL.in~     2014-01-18 05:04:18.000000000 +0100
+++ subversion/bindings/swig/perl/native/Makefile.PL.in      2014-08-15 18:37:33.000000000 +0200
@@ -76,10 +76,15 @@
 
 chomp $apr_shlib_path_var;
 
+my $config_ccflags = $Config{ccflags};
+# remove any -arch arguments, since those
+# we want will already be in $cflags
+$config_ccflags =~ s/-arch\s+\S+//g;
+
 my %config = (
     ABSTRACT => 'Perl bindings for Subversion',
     DEFINE => $cppflags,
-    CCFLAGS => join(' ', $cflags, $Config{ccflags}),
+    CCFLAGS => join(' ', $cflags, $config_ccflags),
     INC  => join(' ', $includes, $cppflags,
                  " -I$swig_srcdir/perl/libsvn_swig_perl",
                  " -I$svnlib_srcdir/include",


Patch 2

--- configure.ac   2014-08-15 19:15:23.000000000 +0200
+++ configure.ac        2014-08-15 19:15:45.000000000 +0200
@@ -1442,6 +1442,10 @@
 # Need to strip '-no-cpp-precomp' from CPPFLAGS for SWIG as well.
 SWIG_CPPFLAGS="$CPPFLAGS"
 SVN_STRIP_FLAG(SWIG_CPPFLAGS, [-no-cpp-precomp ])
+# Swig don't understand "-F" and "-isystem" flags added by Homebrew,
+# so filter them out.
+SVN_STRIP_FLAG(SWIG_CPPFLAGS, [-F\/[[^ ]]* ])
+SVN_STRIP_FLAG(SWIG_CPPFLAGS, [-isystem\/[[^ ]]* ])
 AC_SUBST([SWIG_CPPFLAGS])
 
 dnl Since this is used only on Unix-y systems, define the path separator as '/'
