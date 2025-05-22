class Ctl < Formula
  desc "Programming language for digital color management"
  homepage "https://github.com/ampas/CTL"
  url "https://github.com/ampas/CTL/archive/ctl-1.5.2.tar.gz"
  sha256 "d7fac1439332c4d84abc3c285b365630acf20ea041033b154aa302befd25e0bd"
  revision 1


  depends_on "cmake" => :build
  depends_on "libtiff"
  depends_on "ilmbase"
  depends_on "openexr"
  depends_on "aces_container"

  def install
    ENV.delete "CTL_MODULE_PATH"

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make"
      system "make", "check"
      system "make", "install"
    end
  end

  test do
    assert_match /transforms an image/, shell_output("#{bin}/ctlrender -help", 1)
  end
end
