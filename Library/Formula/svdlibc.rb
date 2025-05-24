class Svdlibc < Formula
  desc "C library to perform singular value decomposition"
  homepage "http://tedlab.mit.edu/~dr/SVDLIBC/"
  url "http://tedlab.mit.edu/~dr/SVDLIBC/svdlibc.tgz"
  version "1.4"
  sha256 "aa1a49a95209801803cc2d9f8792e482b0e8302da8c7e7c9a38e25e5beabe5f8"


  def install
    # make only builds - no configure or install targets, have to copy files manually
    system "make HOSTTYPE=target"
    include.install "svdlib.h"
    lib.install "target/libsvd.a"
    bin.install "target/svd"
  end
end
