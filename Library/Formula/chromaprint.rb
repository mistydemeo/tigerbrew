class Chromaprint < Formula
  desc "Core component of the AcoustID project (Audio fingerprinting)"
  homepage "https://acoustid.org/chromaprint"
  url "https://bitbucket.org/acoustid/chromaprint/downloads/chromaprint-1.2.tar.gz"
  sha256 "822b8949a322ac04c6f8a3ed78f5e689bcc493c6ca0972bf627c913c8430031a"


  option "without-examples", "Don't build examples (including fpcalc)"

  depends_on "cmake" => :build
  depends_on "ffmpeg" if build.with? "examples"

  def install
    args = std_cmake_args
    args << "-DBUILD_EXAMPLES=ON" if build.with? "examples"
    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    system "#{bin}/fpcalc", test_fixtures("test.mp3") if build.with? "examples"
  end
end
