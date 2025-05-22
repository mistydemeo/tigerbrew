class Mongroup < Formula
  desc "Monitor a group of processes with mon"
  homepage "https://github.com/jgallen23/mongroup"
  url "https://github.com/jgallen23/mongroup/archive/0.4.1.tar.gz"
  sha256 "50c6fb0eb6880fa837238a2036f9bc77d2f6db8c66b8c9a041479e2771a925ae"


  depends_on "mon"

  def install
    bin.mkpath
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/mongroup", "-V"
  end
end
