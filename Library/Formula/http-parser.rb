class HttpParser < Formula
  desc "HTTP request/response parser for c"
  homepage "https://github.com/joyent/http-parser"
  url "https://github.com/joyent/http-parser/archive/v2.5.0.tar.gz"
  sha256 "e3b4ba58f4e6ee5fbec781df020e5cb74c3a799a07f059e1e125127a0b801481"


  depends_on "coreutils" => :build

  patch do
    url "https://patch-diff.githubusercontent.com/raw/joyent/http-parser/pull/247.diff"
    sha256 "0f081d0cbf44575b2db2889b318245e692706b756725ba64d1277f571c8b921f"
  end

  def install
    system "make", "install", "PREFIX=#{prefix}", "INSTALL=ginstall"
    share.install "test.c"
  end

  test do
    # Set HTTP_PARSER_STRICT=0 to bypass "tab in URL" test on OS X
    system ENV.cc, share/"test.c", "-o", "test", "-lhttp_parser", "-DHTTP_PARSER_STRICT=0"
    system "./test"
  end
end
