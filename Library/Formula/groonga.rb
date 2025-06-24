class Groonga < Formula
  desc "Fulltext search engine and column store"
  homepage "http://groonga.org/"
  url "http://packages.groonga.org/source/groonga/groonga-5.0.8.tar.gz"
  sha256 "9bc8aca52842a90cbeeb816a2a8ad9c89b226c14fca4c18661039e54587a5a29"


  option "with-benchmark", "With benchmark program for developer use"

  deprecated_option "enable-benchmark" => "with-benchmark"

  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "msgpack"
  depends_on "mecab" => :optional
  depends_on "lz4" => :optional
  depends_on "openssl"
  depends_on "mecab-ipadic" if build.with? "mecab"
  depends_on "glib" if build.with? "benchmark"

  def install
    args = %W[
      --prefix=#{prefix}
      --with-zlib
      --disable-zeromq
      --enable-mruby
      --without-libstemmer
    ]

    args << "--enable-benchmark" if build.with? "benchmark"
    args << "--with-mecab" if build.with? "mecab"
    args << "--with-lz4" if build.with? "lz4"

    # ZeroMQ is an optional dependency that will be auto-detected unless we disable it
    system "./configure", *args
    system "make", "install"
  end

  test do
    output = shell_output("groonga --version")
    assert_match /groonga #{version}/, output
  end
end
