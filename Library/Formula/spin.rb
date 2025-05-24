class Spin < Formula
  desc "Spin model checker"
  homepage "http://spinroot.com/spin/whatispin.html"
  url "http://spinroot.com/spin/Src/spin642.tar.gz"
  version "6.4.2"
  sha256 "d1f3ee841db0da7ba02fe1a04ebd02d316c0760ab8125616d7d2ff46f1c573e5"


  fails_with :llvm do
    build 2334
  end

  def install
    ENV.deparallelize

    cd "Src#{version}" do
      system "make"
      bin.install "spin"
    end

    bin.install "iSpin/ispin.tcl" => "ispin"
    man1.install "Man/spin.1"
  end
end
