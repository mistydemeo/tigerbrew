# Major releases of erlang should typically start out as separate formula in
# Homebrew-versions, and only be merged to master when things like couchdb and
# elixir are compatible.
class Erlang < Formula
  desc "Erlang Programming Language"
  homepage "http://www.erlang.org"

  stable do
    # Download tarball from GitHub; it is served faster than the official tarball.
    url "https://github.com/erlang/otp/archive/OTP-18.1.5.tar.gz"
    sha256 "04824397e6abc91b46b0be26c0a452dc4bc5382f1cbd4fb7b43dd48e7b02bc3a"
  end

  head "https://github.com/erlang/otp.git"

  resource "man" do
    url "http://www.erlang.org/download/otp_doc_man_18.1.tar.gz"
    sha256 "e080e656820b26dd45d806b632e12eec7d1de34f38e5de19a7aebc9fd6e5c9b6"
  end

  resource "html" do
    url "http://www.erlang.org/download/otp_doc_html_18.1.tar.gz"
    sha256 "fe7d035f84492bbf86f8d53891bf31fa327a81ed7dde15c050e9c32615dceb3c"
  end

  option "without-hipe", "Disable building hipe; fails on various OS X systems"
  option "with-native-libs", "Enable native library compilation"
  option "with-dirty-schedulers", "Enable experimental dirty schedulers"
  option "without-docs", "Do not install documentation"

  deprecated_option "disable-hipe" => "without-hipe"
  deprecated_option "no-docs" => "without-docs"

  depends_on "unixodbc" if MacOS.version >= :mavericks
  depends_on "fop" => :optional # enables building PDF docs
  # Need wxWidgets 2.8.4 or above. Tiger include 2.5.3, 3.x needs Leopard minimum.
  depends_on "wxmac" => :recommended if MacOS.version > :tiger # for GUI apps like observer
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "zlib"

  fails_with :llvm

  def install
    # Unset these so that building wx, kernel, compiler and
    # other modules doesn't fail with an unintelligable error.
    %w[LIBS FLAGS AFLAGS ZFLAGS].each { |k| ENV.delete("ERL_#{k}") }

    ENV["FOP"] = "#{HOMEBREW_PREFIX}/bin/fop" if build.with? "fop"

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

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
      # HIPE doesn't strike me as that reliable on OS X
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
