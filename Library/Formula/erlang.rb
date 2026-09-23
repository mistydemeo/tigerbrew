class Erlang < Formula
  desc "Erlang Programming Language"
  homepage "http://www.erlang.org"

  stable do
    url "https://github.com/erlang/otp/archive/OTP-23.3.4.20.tar.gz"
    sha256 "887859a686f3278e2a60435713ade724f97e6222cb7693a5f37c6a894ac42f8e"
  end

  resource "man" do
    url "http://www.erlang.org/download/otp_doc_man_23.3.tar.gz"
    sha256 "b890e99d3fe1b317ed083455985225550ebf74b4a8ec2af4c758e4ce6e2934ff"
  end

  resource "html" do
    url "http://www.erlang.org/download/otp_doc_html_23.3.tar.gz"
    sha256 "03d86ac3e71bb58e27d01743a9668c7a1265b573541d4111590f0f3ec334383e"
  end

  fails_with :gcc_4_0 do
    build 5493
    cause "beam/erl_process.c fails to compile with gcc < 4.4"
  end

  fails_with :gcc do
    build 5577
    cause "beam/erl_process.c fails to compile with gcc < 4.4"
  end

  option "with-dirty-schedulers", "Enable dirty schedulers"
  option "without-docs", "Do not install documentation"

  depends_on "autoconf" => :build
  depends_on "fop" => :optional
  depends_on "wxmac" => :recommended if MacOS.version > :tiger
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "openssl"
  depends_on "zlib"

  def install
    ENV["FOP"] = "#{HOMEBREW_PREFIX}/bin/fop" if build.with? "fop"

    args = %W[
      --disable-debug
      --disable-silent-rules
      --prefix=#{prefix}
      --disable-kernel-poll
      --enable-dynamic-ssl-lib
      --with-ssl=#{Formula["openssl"].opt_prefix}
    ]

    args << "--enable-dirty-schedulers" if build.with? "dirty-schedulers"
    args << "--enable-wx" if build.with? "wxmac"
    args << "--without-javac" if MacOS.version < :snow_leopard
    if MacOS.version >= :snow_leopard && MacOS::CLT.installed?
      args << "--with-dynamic-trace=dtrace"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    if build.with? "docs"
      (lib/"erlang/man").install resource("man")
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