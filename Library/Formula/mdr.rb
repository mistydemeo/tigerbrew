class Mdr < Formula
  desc "Make diffs readable"
  homepage "https://github.com/halffullheart/mdr"
  url "https://github.com/halffullheart/mdr/archive/v1.0.1.tar.gz"
  sha256 "103d52c47133a43cc7a6cb8a21bfabe2d6e35e222d5b675bc0c868699a127c67"


  def install
    system "rake"
    libexec.install Dir["*"]
    bin.install_symlink libexec/"build/dev/mdr"
  end

  test do
    system "#{bin}/mdr", "-h"
  end
end
