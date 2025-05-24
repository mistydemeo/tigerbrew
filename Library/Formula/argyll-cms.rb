class ArgyllCms < Formula
  desc "ICC compatible color management system"
  homepage "http://www.argyllcms.com/"
  url "http://www.argyllcms.com/Argyll_V1.8.2_src.zip"
  version "1.8.2"
  sha256 "59bdfaeace35d2007c90fc53234ba33bf8a64cffc08f7b27a297fc5f85455377"
  revision 1


  depends_on "jam" => :build
  depends_on "jpeg"
  depends_on "libtiff"

  def install
    system "sh", "makeall.sh"
    system "./makeinstall.sh"
    rm "bin/License.txt"
    prefix.install "bin", "ref", "doc"
  end

  test do
    system bin/"targen", "-d", "0", "test.ti1"
    system bin/"printtarg", testpath/"test.ti1"
    %w[test.ti1.ps test.ti1.ti1 test.ti1.ti2].each { |f| File.exist? f }
  end
end
