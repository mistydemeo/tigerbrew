class Megacmd < Formula
  desc "Command-line client for mega.co.nz storage service"
  homepage "https://github.com/t3rm1n4l/megacmd"
  url "https://github.com/t3rm1n4l/megacmd/archive/0.012.tar.gz"
  sha256 "804861f2a7a36eef53a7310e52627e790fa9de66acf8565f697089389d2709a0"
  head "https://github.com/t3rm1n4l/megacmd.git"


  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    system "make"
    bin.install File.basename(buildpath) => "megacmd"
  end

  test do
    system "megacmd", "--version"
  end
end
