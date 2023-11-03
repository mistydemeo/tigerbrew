class Trurl < Formula
  desc "Command-line tool for URL parsing and manipulation"
  homepage "https://curl.se/trurl/"
  url "https://github.com/curl/trurl/archive/refs/tags/trurl-0.9.tar.gz"
  sha256 "848da38c0ea07cd96d6adac4a5e5e141fe26e5bd846039aa350c3ca589a948e0"
  license "curl"
  head "https://github.com/curl/trurl.git", branch: "master"

  bottle do
    cellar :any
    sha256 "01e65134c7a07c6f3acc60ef6ec76f657e13b9a8ee226467b03a9742f3256bcc" => :tiger_altivec
  end

  depends_on "curl" # require libcurl

  def install
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_equal "https 443 /hello.html",
      shell_output("#{bin}/trurl https://example.com/hello.html --get '{scheme} {default:port} {path}'").chomp
  end
end
