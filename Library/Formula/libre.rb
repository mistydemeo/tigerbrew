class Libre < Formula
  desc "Toolkit library for asynchronous network I/O with protocol stacks"
  homepage "http://www.creytiv.com"
  url "http://www.creytiv.com/pub/re-0.4.12.tar.gz"
  sha256 "0d44028ce9c156b2ca34ec7ead8f44a59d3dca57b048edb3410d94cc8b634df2"


  depends_on "openssl"
  depends_on "lzlib"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <re/re.h>
      int main() {
        return libre_init();
      }
    EOS
    system ENV.cc, "test.c", "-lre"
  end
end
