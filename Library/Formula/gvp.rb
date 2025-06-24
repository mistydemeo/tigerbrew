class Gvp < Formula
  desc "Go versioning packager"
  homepage "https://github.com/pote/gvp"
  url "https://github.com/pote/gvp/archive/v0.2.0.tar.gz"
  sha256 "ede10a32889cf284eaa4c4a9ed4e6bc0a85e0663246bf2fb7c1cf3965db661ea"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/gvp", "init"
    assert File.directory? ".godeps/src"
  end
end
