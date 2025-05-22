class Libsoxr < Formula
  desc "High quality, one-dimensional sample-rate conversion library"
  homepage "http://sourceforge.net/projects/soxr/"
  url "https://downloads.sourceforge.net/project/soxr/soxr-0.1.1-Source.tar.xz"
  mirror "https://mirrors.kernel.org/debian/pool/main/libs/libsoxr/libsoxr_0.1.1.orig.tar.xz"
  sha256 "dcc16868d1a157079316f84233afcc2b52dd0bd541dd8439dc25bceb306faac2"


  depends_on :ld64
  depends_on "cmake" => :build

  conflicts_with "sox", :because => "Sox contains soxr. Soxr is purely the resampler."

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
