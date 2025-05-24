class Slurm < Formula
  desc "Yet another network load monitor"
  homepage "https://github.com/mattthias/slurm"
  url "https://github.com/mattthias/slurm/archive/upstream/0.4.2.tar.gz"
  sha256 "8a28e11650928d87a907f9b154f6efd1ad5854cdc56a528da2e02e756e0aa58e"


  depends_on "scons" => :build

  def install
    scons
    bin.install "slurm"
  end

  test do
    system "#{bin}/slurm", "-h"
  end
end
