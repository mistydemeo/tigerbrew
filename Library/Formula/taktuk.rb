class Taktuk < Formula
  desc "Deploy commands to (a potentially large set of) remote nodes"
  homepage "http://taktuk.gforge.inria.fr/"
  url "http://gforge.inria.fr/frs/download.php/30903/taktuk-3.7.5.tar.gz"
  sha256 "62d1b72616a1b260eb87cecde2e21c8cbb844939f2dcafad33507fcb16ef1cb1"


  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    ENV.j1
    system "make", "install"
  end

  test do
    system "#{bin}/taktuk", "quit"
  end
end
