class Libical < Formula
  desc "Implementation of iCalendar protocols and data formats"
  homepage "http://www.citadel.org/doku.php/documentation:featured_projects:libical"
  url "https://github.com/libical/libical/releases/download/v1.0.1/libical-1.0.1.tar.gz"
  sha256 "089ce3c42d97fbd7a5d4b3c70adbdd82115dd306349c1f5c46a8fb3f8c949592"


  depends_on "cmake" => :build

  option :universal

  def install
    args = std_cmake_args
    if build.universal?
      ENV.universal_binary
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.universal_archs.as_cmake_arch_flags}"
    end

    mkdir "build" do
      system "cmake", "..", "-DSHARED_ONLY=true", *args
      system "make", "install"
    end
  end
end
