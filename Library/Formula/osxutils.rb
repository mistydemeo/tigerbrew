class Osxutils < Formula
  desc "CLI access of Mac-specific information, settings, and metadata"
  homepage "https://github.com/specious/osxutils"
  url "https://github.com/specious/osxutils/archive/refs/tags/v1.9.0.tar.gz"
  sha256 "9c11d989358ed5895d9af7644b9295a17128b37f41619453026f67e99cb7ecab"
  license "GPL-2.0"
  head "https://github.com/vasi/osxutils.git"

  bottle do
    sha256 "829147ce1b532e370070bce1ca301c15c52124e5cdd016feb578d177e2af6a65" => :tiger_altivec
  end

  def install
    system "make"
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    assert_match "osxutils", shell_output("#{bin}/osxutils")
  end
end
