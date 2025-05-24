class Camlistore < Formula
  desc "Content-addressable multi-layer indexed storage"
  homepage "https://camlistore.org"
  url "https://github.com/camlistore/camlistore/archive/0.8.tar.gz"
  sha256 "61b75708ae25ac4dc1c5c31c1cf8f806ccaafaaacf618caf1aa9d31489fec50f"
  head "https://camlistore.googlesource.com/camlistore", :using => :git


  conflicts_with "hello", :because => "both install `hello` binaries"

  depends_on "pkg-config" => :build
  depends_on "go" => :build
  depends_on "sqlite"

  def install
    system "go", "run", "make.go"
    prefix.install "bin/README"
    prefix.install "bin"
  end

  test do
    system bin/"camget", "-version"
  end
end
