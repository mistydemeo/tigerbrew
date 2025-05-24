class Srtp < Formula
  desc "Implementation of the Secure Real-time Transport Protocol (SRTP)"
  homepage "https://github.com/cisco/libsrtp"
  url "https://github.com/cisco/libsrtp/archive/v1.5.2.tar.gz"
  sha256 "86e1efe353397c0751f6bdd709794143bd1b76494412860f16ff2b6d9c304eda"
  head "https://github.com/cisco/libsrtp.git"


  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make", "shared_library"
    system "make", "install" # Can't go in parallel of building the dylib
  end
end
