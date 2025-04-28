# Major releases of erlang should typically start out as separate formula in
# Homebrew-versions, and only be merged to master when things like couchdb and
# elixir are compatible.
class Erlang < Formula
  desc "Erlang Programming Language"
  homepage "http://www.erlang.org"

  head "https://github.com/erlang/otp.git"

  stable do
    # Download tarball from GitHub; it is served faster than the official tarball.
    url "https://github.com/erlang/otp/archive/OTP-18.3.4.11.tar.gz"
    sha256 "94f84e8ca0db0dcadd3411fa7a05dd937142b6ae830255dc341c30b45261b01a"
  end

  resource "man" do
    url "http://www.erlang.org/download/otp_doc_man_18.3.tar.gz"
    sha256 "978be100e9016874921b3ad1a65ee46b7b6a1e597b8db2ec4b5ef436d4c9ecc2"
  end

  resource "html" do
    url "http://www.erlang.org/download/otp_doc_html_18.3.tar.gz"
    sha256 "8fd6980fd05367735779a487df107ace7c53733f52fbe56de7ca7844a355676f"
  end

  # Current autoconf (2.7.x) has trouble dealing with $ERL_TOP, resulting in
  # configure: error: cannot find required auxiliary files: install-sh config.guess config.sub
  patch :p0, :DATA

  option "without-hipe", "Disable building HiPE (High-Performance Erlang); fails on various OS X systems"
  option "with-native-libs", "Enable native library compilation"
  option "with-dirty-schedulers", "Enable experimental dirty schedulers"
  option "without-docs", "Do not install documentation"

  deprecated_option "disable-hipe" => "without-hipe"
  deprecated_option "no-docs" => "without-docs"

  depends_on "autoconf" => :build
  depends_on "unixodbc" if MacOS.version >= :mavericks
  depends_on "fop" => :optional # enables building PDF docs
  # Need wxWidgets 2.8.4 or above. Tiger includes 2.5.3, 3.x needs Leopard minimum.
  depends_on "wxmac" => :recommended if MacOS.version > :tiger # for GUI apps like observer
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "zlib"

  fails_with :gcc do
    build 5666
    cause "Bus error when attempting to build HiPE"
  end

  def install
    # Unset these so that building wx, kernel, compiler and
    # other modules doesn't fail with an unintelligable error.
    %w[LIBS FLAGS AFLAGS ZFLAGS].each { |k| ENV.delete("ERL_#{k}") }

    ENV["FOP"] = "#{HOMEBREW_PREFIX}/bin/fop" if build.with? "fop"

    # Do this if building from a checkout to generate configure
    system "./otp_build", "autoconf" if File.exist? "otp_build"

    args = %W[
      --disable-debug
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-kernel-poll
      --enable-threads
      --enable-shared-zlib
      --enable-smp-support
    ]

    args << "--enable-darwin-64bit" if MacOS.prefer_64_bit?
    args << "--enable-native-libs" if build.with? "native-libs"
    args << "--enable-dirty-schedulers" if build.with? "dirty-schedulers"
    args << "--enable-wx" if build.with? "wxmac"
    # Older Javas not supported by jinterface
    # https://github.com/mistydemeo/tigerbrew/issues/372
    args << "--without-javac" if MacOS.version < :snow_leopard
    # error: cannot compute sizeof (__int128_t, 77)
    # In /usr/include/c++/4.0.0/powerpc64-apple-darwin8/bits/stdc++.h.gch/O0g.gch & O2g.gch
    # symbol is found but configure's test for it fails, breaking the build
    args << "ac_cv_type___int128_t=no" if MacOS.version == :tiger && Hardware::CPU.family == :g5

    if MacOS.version >= :snow_leopard && MacOS::CLT.installed?
      args << "--with-dynamic-trace=dtrace"
    end

    if build.without? "hipe"
      # HiPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << "--disable-hipe"
    else
      args << "--enable-hipe"
    end

    system "./configure", *args
    system "make"
    ENV.j1 # Install is not thread-safe; can try to create folder twice and fail
    system "make", "install"

    if build.with? "docs"
      (lib/"erlang").install resource("man").files("man")
      doc.install resource("html")
    end
  end

  def caveats; <<-EOS.undent
    Man pages can be found in:
      #{opt_lib}/erlang/man

    Access them with `erl -man`, or add this directory to MANPATH.
    EOS
  end

  test do
    system "#{bin}/erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end
__END__
--- lib/snmp/configure.in.orig	2025-04-28 01:39:37.000000000 +0100
+++ lib/snmp/configure.in	2025-04-28 01:40:16.000000000 +0100
@@ -4,12 +4,8 @@
 
 AC_INIT(vsn.mk)
 
-if test -z "$ERL_TOP" || test ! -d $ERL_TOP ; then
-  AC_CONFIG_AUX_DIRS(autoconf)
-else
-  erl_top=${ERL_TOP}
-  AC_CONFIG_AUX_DIRS($erl_top/erts/autoconf)
-fi
+erl_top=${ERL_TOP}
+AC_CONFIG_AUX_DIRS(../../erts/autoconf)
 
 if test "X$host" != "Xfree_source" -a "X$host" != "Xwin32"; then
     AC_CANONICAL_HOST
--- lib/megaco/configure.in.orig	2025-04-28 01:40:32.000000000 +0100
+++ lib/megaco/configure.in	2025-04-28 01:40:56.000000000 +0100
@@ -29,12 +29,8 @@
 
 AC_INIT(vsn.mk)
 
-if test -z "$ERL_TOP" || test ! -d $ERL_TOP ; then
-  AC_CONFIG_AUX_DIRS(autoconf)
-else
-  erl_top=${ERL_TOP}
-  AC_CONFIG_AUX_DIRS($erl_top/erts/autoconf)
-fi
+erl_top=${ERL_TOP}
+AC_CONFIG_AUX_DIRS(../../erts/autoconf)
 
 if test "X$host" != "Xfree_source" -a "X$host" != "Xwin32"; then
     AC_CANONICAL_HOST
--- lib/odbc/configure.in.orig	2025-04-28 01:41:20.000000000 +0100
+++ lib/odbc/configure.in	2025-04-28 01:41:44.000000000 +0100
@@ -31,12 +31,8 @@
 dnl Process this file with autoconf to produce a configure script.
 AC_INIT(c_src/odbcserver.c)
 
-if test -z "$ERL_TOP" || test ! -d $ERL_TOP ; then
-  AC_CONFIG_AUX_DIRS(autoconf)
-else
-  erl_top=${ERL_TOP}
-  AC_CONFIG_AUX_DIRS($erl_top/erts/autoconf)
-fi
+erl_top=${ERL_TOP}
+AC_CONFIG_AUX_DIRS(../../erts/autoconf)
 
 if test "X$host" != "Xfree_source" -a "X$host" != "Xwin32"; then
     AC_CANONICAL_HOST
--- lib/gs/configure.in.orig	2025-04-28 01:44:20.000000000 +0100
+++ lib/gs/configure.in	2025-04-28 01:44:54.000000000 +0100
@@ -8,7 +8,7 @@
   AC_MSG_ERROR(You need to set the environment variable ERL_TOP!)
 fi
 erl_top=${ERL_TOP}
-AC_CONFIG_AUX_DIRS($erl_top/erts/autoconf)
+AC_CONFIG_AUX_DIRS(../../erts/autoconf)
 
 dnl FIXME: Should be AC_CANONICAL_TARGET but we follow pattern in
 dnl main configure.in.
