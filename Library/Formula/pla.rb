class Pla < Formula
  desc "Tool for building Gantt charts in PNG, EPS, PDF or SVG format"
  homepage "http://www.arpalert.org/pla.html"
  url "http://www.arpalert.org/src/pla-1.2.tar.gz"
  sha256 "c2f1ce50b04032abf7f88ac07648ea40bed2443e86e9f28f104d341965f52b9c"


  depends_on "cairo"
  depends_on "pkg-config" => :build

  def install
    system "make"
    bin.install "pla"
  end

  test do
    (testpath/"test.pla").write <<-EOS.undent
    [4] REF0 Install des serveurs
      color #8cb6ce
      child 1
      child 2
      child 3

      [1] REF0 Install 1
        start 2010-04-08 01
        duration 24
        color #8cb6ce
        dep 2
        dep 6
        EOS
    system "#{bin}/pla", "-i", "#{testpath}/test.pla", "-o test"
  end
end
