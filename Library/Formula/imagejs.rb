class Imagejs < Formula
  desc "Tool to hide JavaScript inside valid image files"
  homepage "http://jklmnn.de/imagejs/"
  url "https://github.com/jklmnn/imagejs/archive/0.7.1.tar.gz"
  sha256 "d1a1368ce72a1a7d18d053f82bf19c7af14861588a459f3bf69f2b50a335633f"
  head "https://github.com/jklmnn/imagejs.git"


  def install
    system "make"
    bin.install "imagejs"
  end

  test do
    (testpath/"test.js").write "alert('Hello World!')"
    system "#{bin}/imagejs", "bmp", "test.js", "-l"
  end
end
