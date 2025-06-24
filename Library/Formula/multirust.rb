class Multirust < Formula
  homepage "https://github.com/brson/multirust"
  desc "Manage multiple Rust installations"

  # Use the tag instead of the tarball to get submodules
  url "https://github.com/brson/multirust.git",
    :tag => "0.0.6",
    :revision => "6b18101d0b878669bdba94b9e37c31308dc12d34"

  head "https://github.com/brson/multirust.git"


  depends_on :gpg => [:recommended, :run]

  def install
    system "./build.sh"
    system "./install.sh", "--prefix=#{prefix}"
  end

  test do
    system "#{bin}/multirust", "show-default"
  end
end
