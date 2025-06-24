class FbClient < Formula
  desc "Shell-script client for http://paste.xinu.at"
  homepage "https://paste.xinu.at"
  url "https://paste.xinu.at/data/client/fb-1.5.0.tar.gz"
  sha256 "205514e7ae6d2ce687c05a5f581248d0f06c29c4e8e004f768ba0b54a39ed2f3"

  head "https://git.server-speed.net/users/flo/fb", :using => :git


  conflicts_with "findbugs",
    :because => "findbugs and fb-client both install a `fb` binary"

  depends_on "pkg-config" => :build

  def install
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system bin/"fb", "-h"
  end
end
