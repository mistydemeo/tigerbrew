class Libfreenect < Formula
  desc "Drivers and libraries for the Xbox Kinect device"
  homepage "http://openkinect.org"
  url "https://github.com/OpenKinect/libfreenect/archive/v0.5.1.tar.gz"
  sha256 "97e5dd11a0f292b6a3014d1a31c7af16a21cd6574a63057ed7a364064a7614d0"

  head "https://github.com/OpenKinect/libfreenect.git"


  option :universal

  depends_on "cmake" => :build
  depends_on "libusb"

  def install
    args = std_cmake_args
    args << "-DBUILD_OPENNI2_DRIVER=ON"

    if build.universal?
      ENV.universal_binary
      args << "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.universal_archs.as_cmake_arch_flags}"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end
end
