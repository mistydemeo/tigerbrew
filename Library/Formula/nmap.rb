class Nmap < Formula
  desc "Port scanning utility for large networks"
  homepage "https://nmap.org/"
  license :cannot_represent
  head "https://svn.nmap.org/nmap/"

  # TODO: Remove stable block in next release.
  stable do
    url "https://nmap.org/dist/nmap-7.94.tar.bz2"
    sha256 "d71be189eec43d7e099bac8571509d316c4577ca79491832ac3e1217bc8f92cc"

    # Fix build with Lua 5.4. Remove in next release.
    patch do
      url "https://github.com/nmap/nmap/commit/b9263f056ab3acd666d25af84d399410560d48ac.patch?full_index=1"
      sha256 "088d426dc168b78ee4e0450d6b357deef13e0e896b8988164ba2bb8fd8b8767c"
    end

    # Backport pcre2 support. Remove in next release.
    patch :DATA # https://github.com/nmap/nmap/commit/85f38cb858065d4b0e384730258494e8639887db
    patch do
      url "https://github.com/nmap/nmap/commit/828ab48764b82d0226e860c73c5dac5b11f77385.patch?full_index=1"
      sha256 "3b5febc6c10acc59bff1c43e252d221b9c9be0cd4d866294f91f40a5d008eff0"
    end
    patch do
      url "https://github.com/nmap/nmap/commit/d131a096a869195be36ef7d4fa36739373346cb2.patch?full_index=1"
      sha256 "5acbcae9f3ef33b9fe38005c0b3c0df4154fb2ae6e0bc38a915f45d473f71c66"
    end
  end

  bottle do
  end

  # Need better C++ support from compiler
  # osscan.h:157: error: ‘const class std::map<ShortStr<5u>, FingerPrintDef::TestID, std::less<ShortStr<5u> >, std::allocator<std::pair<const ShortStr<5u>, FingerPrintDef::TestID> > >’ has no member named ‘at’
  # osscan.h:158: error: ‘const class std::map<ShortStr<5u>, FingerPrintDef::TestID, std::less<ShortStr<5u> >, std::allocator<std::pair<const ShortStr<5u>, FingerPrintDef::TestID> > >’ has no member named ‘at’
  fails_with :gcc
  fails_with :gcc_4_0

  depends_on "liblinear"
  depends_on "libssh2"
  # Check supported Lua version at https://github.com/nmap/nmap/tree/master/liblua.
  depends_on "lua"
  depends_on "openssl3"
  depends_on "pcre2"
  depends_on "python3" => :run # For ndiff

  depends_on "bison" => :build
  depends_on "flex" => :build
  depends_on "libpcap"
  depends_on "zlib"

  conflicts_with "ndiff", :because => "both install `ndiff` binaries"

  def install
    ENV.deparallelize

    args = %W[
      --prefix=#{prefix}
      --with-liblua=#{Formula["lua"].opt_prefix}
      --with-libpcre=#{Formula["pcre2"].opt_prefix}
      --with-openssl=#{Formula["openssl3"].opt_prefix}
      --with-libpcap=#{Formula["libpcap"].opt_prefix}
      --without-nmap-update
      --disable-universal
      --without-zenmap
    ]

    # cpp-precomp support was exclusive to Apple's compilers
    # Remove in next release. https://github.com/nmap/nmap/pull/2777
    system "sed -i -e '/needs_cpp_precomp=yes/d' configure"
    system "sed -i -e '/needs_cpp_precomp=yes/d' nping/configure"

    system "./configure", *args
    system "make" # separate steps required otherwise the build fails
    system "make", "install"

    (bin/"uninstall_ndiff").unlink # Users should use brew uninstall.
  end

  def caveats
      <<~EOS
        If using `ndiff` returns an error about not being able to import the ndiff module, try:
          chmod go-w #{HOMEBREW_CELLAR}
      EOS
  end

  test do
    system bin/"nmap", "-p80,443", "scanme.nmap.org"
  end
end

__END__
diff --git a/configure b/configure
index d1d2f19e0d..30a455492e 100755
--- a/configure
+++ b/configure
@@ -754,7 +754,6 @@ infodir
 docdir
 oldincludedir
 includedir
-runstatedir
 localstatedir
 sharedstatedir
 sysconfdir
@@ -853,7 +852,6 @@ datadir='${datarootdir}'
 sysconfdir='${prefix}/etc'
 sharedstatedir='${prefix}/com'
 localstatedir='${prefix}/var'
-runstatedir='${localstatedir}/run'
 includedir='${prefix}/include'
 oldincludedir='/usr/include'
 docdir='${datarootdir}/doc/${PACKAGE}'
@@ -1106,15 +1104,6 @@ do
   | -silent | --silent | --silen | --sile | --sil)
     silent=yes ;;
 
-  -runstatedir | --runstatedir | --runstatedi | --runstated \
-  | --runstate | --runstat | --runsta | --runst | --runs \
-  | --run | --ru | --r)
-    ac_prev=runstatedir ;;
-  -runstatedir=* | --runstatedir=* | --runstatedi=* | --runstated=* \
-  | --runstate=* | --runstat=* | --runsta=* | --runst=* | --runs=* \
-  | --run=* | --ru=* | --r=*)
-    runstatedir=$ac_optarg ;;
-
   -sbindir | --sbindir | --sbindi | --sbind | --sbin | --sbi | --sb)
     ac_prev=sbindir ;;
   -sbindir=* | --sbindir=* | --sbindi=* | --sbind=* | --sbin=* \
@@ -1252,7 +1241,7 @@ fi
 for ac_var in	exec_prefix prefix bindir sbindir libexecdir datarootdir \
 		datadir sysconfdir sharedstatedir localstatedir includedir \
 		oldincludedir docdir infodir htmldir dvidir pdfdir psdir \
-		libdir localedir mandir runstatedir
+		libdir localedir mandir
 do
   eval ac_val=\$$ac_var
   # Remove trailing slashes.
@@ -1405,7 +1394,6 @@ Fine tuning of the installation directories:
   --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
   --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
   --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
-  --runstatedir=DIR       modifiable per-process data [LOCALSTATEDIR/run]
   --libdir=DIR            object code libraries [EPREFIX/lib]
   --includedir=DIR        C header files [PREFIX/include]
   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
