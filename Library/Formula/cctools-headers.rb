# The system versions are too old to build ld64
class CctoolsHeaders < Formula
  desc "cctools-headers via Apple"
  homepage "https://github.com/apple-oss-distributions/cctools/tree/cctools-855"
  url "https://github.com/apple-oss-distributions/cctools/archive/refs/tags/cctools-855.tar.gz"
  sha256 "7c31652cefde324fd6dc6f4dabbcd936986430039410a65c98d4a7183695f6d7"

  keg_only :provided_by_osx

  resource "headers" do
    url "https://github.com/apple-oss-distributions/xnu/archive/refs/tags/xnu-2422.90.20.tar.gz"
    sha256 "58c42f91e690dea501ba8f3e2ec47db68d975d9e72cae2bbf508df1e3ab5504b"
  end

  def install
    # only supports DSTROOT, not PREFIX
    inreplace "include/Makefile", "/usr/include", "/include"
    system "make", "installhdrs", "DSTROOT=#{prefix}", "RC_ProjectSourceVersion=#{version}"
    # installs some headers we don't need to DSTROOT/usr/local/include
    (prefix/"usr").rmtree

    # ld64 requires an updated mach/machine.h to build
    resource("headers").stage { (include/"mach").install "osfmk/mach/machine.h" }
  end
end
