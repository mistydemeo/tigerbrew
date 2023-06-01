class Trurl < Formula
  desc "Command-line tool for URL parsing and manipulation"
  homepage "https://curl.se/trurl/"
  url "https://github.com/curl/trurl/archive/refs/tags/trurl-0.7.tar.gz"
  sha256 "11616a4c3d255ff3347cb8fc65ea4f890526f327800ec556d78e88881e2cbfa7"
  license "curl"
  head "https://github.com/curl/trurl.git", branch: "master"

  depends_on "curl" # require libcurl

  def install
    # GCC 4.x defaults to c89 and fails to build
    ENV.append_to_cflags "-std=gnu99"
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_equal "https 443 /hello.html",
      shell_output("#{bin}/trurl https://example.com/hello.html --get '{scheme} {port} {path}'").chomp
  end

  # Allow cflags to be appended
  patch :p0, :DATA
end
__END__
--- Makefile.orig	2023-06-01 14:27:24.000000000 +0100
+++ Makefile	2023-06-01 14:28:24.000000000 +0100
@@ -1,7 +1,7 @@
 TARGET = trurl
 OBJS = trurl.o
 LDLIBS = $$(curl-config --libs)
-CFLAGS = $$(curl-config --cflags) -W -Wall -Wshadow -Werror -pedantic -g
+CFLAGS += $$(curl-config --cflags) -W -Wall -Wshadow -Werror -pedantic -g
 MANUAL = trurl.1
 
 PREFIX ?= /usr/local
