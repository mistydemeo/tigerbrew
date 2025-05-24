class Liblastfm < Formula
  desc "Libraries for Last.fm site services"
  homepage "https://github.com/lastfm/liblastfm/"
  url "https://github.com/lastfm/liblastfm/archive/1.0.9.tar.gz"
  sha256 "5276b5fe00932479ce6fe370ba3213f3ab842d70a7d55e4bead6e26738425f7b"


  depends_on "pkg-config" => :build
  depends_on "cmake" => :build
  depends_on "qt"
  depends_on "fftw"
  depends_on "libsamplerate"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end
