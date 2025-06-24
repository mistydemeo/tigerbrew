class Sfk < Formula
  desc "Command Line Tools Collection"
  homepage "http://stahlworks.com/dev/swiss-file-knife.html"
  url "https://downloads.sourceforge.net/project/swissfileknife/1-swissfileknife/1.7.5/sfk-1.7.5.tar.gz"
  sha256 "f15b4bd974285138d857500ddf4563d8e77146ece967867944f09edb15e745c7"


  def install
    # Using the standard ./configure && make install method does not work with sfk as of this version
    # As per the build instructions for OS X, this is all you need to do to build sfk
    system ENV.cxx, "-DMAC_OS_X", "sfk.cpp", "sfkext.cpp", "-o", "sfk"

    # The sfk binary is all you need. There are no man pages or share files
    bin.install "sfk"
  end

  test do
    system "sfk", "ip"
  end
end
