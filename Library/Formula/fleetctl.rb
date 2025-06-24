class Fleetctl < Formula
  desc "Distributed init system"
  homepage "https://github.com/coreos/fleet"
  url "https://github.com/coreos/fleet/archive/v0.11.5.tar.gz"
  sha256 "a6a785099df71645b5fe8755a36baa6c11138749bc02ae4990fd3f52663c0394"
  head "https://github.com/coreos/fleet.git"


  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    system "./build"
    bin.install "bin/fleetctl"
  end

  test do
    system "#{bin}/fleetctl", "-version"
  end
end
