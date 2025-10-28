class Git < Formula
  desc "Distributed revision control system"
  homepage "https://git-scm.com"
  url "https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.50.1.tar.xz"
  sha256 "7e3e6c36decbd8f1eedd14d42db6674be03671c2204864befa2a41756c5c8fc4"
  license "GPL-2.0-only"
  head "https://github.com/git/git.git", :shallow => false

  bottle do
  end

  resource "html" do
    url "https://mirrors.edge.kernel.org/pub/software/scm/git/git-htmldocs-2.50.1.tar.xz"
    sha256 "d15ccd1518b822e317d14b63de4444bb288909294f117cbbfa385c60ab739bca"
  end

  resource "man" do
    url "https://mirrors.edge.kernel.org/pub/software/scm/git/git-manpages-2.50.1.tar.xz"
    sha256 "7dd86882bbc22bef8852924de96b9cb378aad8532089e301c82093da3e7c5478"
  end

  # Fix PowerPC build and support for OS X Tiger & Leopard
  # e.g supplied regex(3) is too old, lacks some file system monitoring functionality
  # Needs arc4random_buf(3) which is missing on Leopard and prior so just use openssl
  # since newer implementations were based on AES cipher.
  # copyfile.h didn't show up until Leopard.
  # error: use of undeclared identifier 'O_RDONLY' & 'O_EXLOCK'
  patch :p0, :DATA

  option "with-blk-sha1", "Compile with the block-optimized SHA1 implementation"
  option "without-completions", "Disable bash/zsh completions from 'contrib' directory"
  option "with-brewed-svn", "Use Homebrew's version of SVN"
  option "with-persistent-https", "Build git-remote-persistent-https from 'contrib' directory"

  if MacOS.version == :tiger
    # system tar has odd permissions errors
    depends_on "gnu-tar" => :build
  end

  depends_on :expat
  depends_on "pcre2" => :optional
  depends_on "gettext"
  depends_on "openssl3"
  depends_on "openssh" => :run
  depends_on "curl"
  depends_on "make" => :build
  depends_on "libiconv"
  depends_on "zlib"
  depends_on "go" => :build if build.with? "persistent-https"
  # Trigger an install of swig before subversion, as the "swig" doesn't get pulled in otherwise
  # See https://github.com/Homebrew/homebrew/issues/34554
  if build.with? "brewed-svn"
    depends_on "swig"
    depends_on "subversion" => "with-perl"
  end

  # https://github.com/mistydemeo/tigerbrew/issues/1250
  fails_with :gcc do
    build 5553
    cause "Misoptimization, fails to fetch certain repos"
  end

  def install
    # GCC is invoked with -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

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
    ENV["CURLDIR"] = Formula["curl"].opt_prefix
    ENV["NO_APPLE_COMMON_CRYPTO"] = "1" if MacOS.version < :leopard
    ENV["NO_TCLTK"] = "1" if MacOS.version <:snow_leopard # Needs Tcl-Tk 8.5 or newer with Aqua support
    ENV.append "CFLAGS", "-std=gnu99"

    perl_version = /\d\.\d+/.match(`perl --version`)

    if build.with? "brewed-svn"
      ENV["PERLLIB_EXTRA"] = %W[
        #{Formula["subversion"].opt_lib}/perl5/site_perl
        #{Formula["subversion"].opt_prefix}/Library/Perl/#{perl_version}/darwin-thread-multi-2level
      ].join(":")
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

    if build.with? "pcre2"
      ENV["USE_LIBPCRE"] = "1"
      ENV["LIBPCREDIR"] = Formula["pcre2"].opt_prefix
    end

    ENV["NO_GETTEXT"] = "1" if build.without? "gettext"

    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      CC=#{ENV.cc}
      CFLAGS=#{ENV.cflags}
      LDFLAGS=#{ENV.ldflags}
    ]

    system "gmake", "install", *args

    if MacOS.version >= :lion
    # Install the OS X keychain credential helper
    # Needs Security.framework from 10.7 or newer
    cd "contrib/credential/osxkeychain" do
      system "gmake", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-credential-osxkeychain"
      system "gmake", "clean"
    end
    end

    # Install git-subtree
    cd "contrib/subtree" do
      system "gmake", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-subtree"
    end

    if build.with? "persistent-https"
      cd "contrib/persistent-https" do
        system "gmake"
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

    if MacOS.version >= :lion
    # Set the macOS keychain credential helper by default
    # (as Apple's CLT's git also does this).
    (buildpath/"gitconfig").write <<-EOS.undent
      [credential]
      \thelper = osxkeychain
    EOS
    etc.install "gitconfig"
    end
  end

  def caveats
    osxkeychain_text = <<-EOS.undent

    The OS X keychain credential helper has been installed to:
      #{HOMEBREW_PREFIX}/bin/git-credential-osxkeychain
    EOS

    text = <<-EOS.undent
    The "contrib" directory has been installed to:
      #{HOMEBREW_PREFIX}/share/git-core/contrib
    EOS

    text += osxkeychain_text if MacOS.version >= :lion
    text
  end

  test do
    system bin/"git", "init"
    %w[haunted house].each { |f| touch testpath/f }
    system bin/"git", "add", "haunted", "house"
    system bin/"git", "commit", "-a", "-m", "Initial Commit"
    assert_equal "haunted\nhouse", shell_output("#{bin}/git ls-files").strip
  end
end
__END__
--- sha1dc/sha1.c.orig	2023-04-08 03:00:31.000000000 +0000
+++ sha1dc/sha1.c
@@ -102,6 +102,10 @@
  */
 #define SHA1DC_BIGENDIAN
 
+#elif (defined(__APPLE__) && defined(__BIG_ENDIAN__) && !defined(SHA1DC_BIGENDIAN))
+/* older gcc compilers which are the default on Apple PPC do not define __BYTE_ORDER__ */
+#define SHA1DC_BIGENDIAN
+
 /* Not under GCC-alike or glibc or *BSD or newlib or <processor whitelist> or <os whitelist> */
 #elif defined(SHA1DC_ON_INTEL_LIKE_PROCESSOR)
 /*
--- config.mak.uname.orig	2024-04-30 21:58:33.000000000 +0100
+++ config.mak.uname	2024-04-30 22:01:59.000000000 +0100
@@ -128,6 +128,11 @@
 		OLD_ICONV = UnfortunatelyYes
 		NO_APPLE_COMMON_CRYPTO = YesPlease
         endif
+        ifeq ($(shell test "`expr "$(uname_R)" : '\([0-9][0-9]*\)\.'`" -lt 12 && echo 1),1)
+		NO_REGEX=YesPlease 
+        else
+		USE_ENHANCED_BASIC_REGULAR_EXPRESSIONS = YesPlease
+        endif
         ifeq ($(shell expr "$(uname_R)" : '[15]\.'),2)
 		NO_STRLCPY = YesPlease
         endif
@@ -146,8 +151,7 @@
 	HAVE_BSD_SYSCTL = YesPlease
 	FREAD_READS_DIRECTORIES = UnfortunatelyYes
 	HAVE_NS_GET_EXECUTABLE_PATH = YesPlease
-	CSPRNG_METHOD = arc4random
-	USE_ENHANCED_BASIC_REGULAR_EXPRESSIONS = YesPlease
+	CSPRNG_METHOD = openssl
 
 	# Workaround for `gettext` being keg-only and not even being linked via
 	# `brew link --force gettext`, should be obsolete as of
@@ -173,6 +177,7 @@
                 endif
         endif
 
+	ifeq ($(shell test "`expr "$(uname_R)" : '\([0-9][0-9]*\)\.'`" -gt 13 && echo 1), 1)
 	# The builtin FSMonitor on MacOS builds upon Simple-IPC.  Both require
 	# Unix domain sockets and PThreads.
         ifndef NO_PTHREADS
@@ -181,6 +186,7 @@
 	FSMONITOR_OS_SETTINGS = darwin
         endif
         endif
+        endif
 
 	BASIC_LDFLAGS += -framework CoreServices
 endif
--- Makefile.orig       2023-05-19 19:22:10.000000000 +0100
+++ Makefile    2023-05-19 19:22:53.000000000 +0100
@@ -1351,7 +1351,7 @@
 # Older versions of GCC may require adding "-std=gnu99" at the end.
 CFLAGS = -g -O2 -Wall
 LDFLAGS =
-CC_LD_DYNPATH = -Wl,-rpath,
+CC_LD_DYNPATH = -L
 BASIC_CFLAGS = -I.
 BASIC_LDFLAGS =
 

--- t/unit-tests/clar/clar/fs.h.orig	2024-10-23 18:35:26.000000000 +0100
+++ t/unit-tests/clar/clar/fs.h	2024-10-23 18:37:45.000000000 +0100
@@ -318,7 +318,10 @@
 #endif
 
 #if defined(__APPLE__)
+# include <AvailabilityMacros.h>
+# if MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
 # include <copyfile.h>
+# endif
 #endif
 
 static void basename_r(const char **out, int *out_len, const char *in)
--- contrib/credential/osxkeychain/git-credential-osxkeychain.c.orig	2025-02-09 23:11:13.000000000 +0000
+++ contrib/credential/osxkeychain/git-credential-osxkeychain.c	2025-02-09 23:11:36.000000000 +0000
@@ -1,6 +1,7 @@
 #include <stdio.h>
 #include <string.h>
 #include <stdlib.h>
+#include <sys/fcntl.h>
 #include <Security/Security.h>
 
 #define ENCODING kCFStringEncodingUTF8
