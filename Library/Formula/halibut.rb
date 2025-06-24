class Halibut < Formula
  desc "Yet another free document preparation system"
  homepage "http://www.chiark.greenend.org.uk/~sgtatham/halibut/"
  url "http://www.chiark.greenend.org.uk/~sgtatham/halibut/halibut-1.1.tar.gz"
  sha256 "b964950d11ed09d3af28ac095da539613f6e50d650f01fe72b4ae752724c80a0"

  head "git://git.tartarus.org/simon/halibut.git"


  def install
    bin.mkpath
    man1.mkpath

    system "make", "prefix=#{prefix}", "mandir=#{man}", "all"
    system "make", "-C", "doc", "prefix=#{prefix}", "mandir=#{man}"
    system "make", "prefix=#{prefix}", "mandir=#{man}", "install"
  end

  test do
    (testpath/"sample.but").write("Hello, world!")
    system "#{bin}/halibut", "--html=sample.html", "sample.but"

    assert_match("<p>\nHello, world!\n<\/p>",
                 (testpath/"sample.html").read)
  end
end
