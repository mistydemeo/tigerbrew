class Libftdi < Formula
  desc "Library to talk to FTDI chips"
  homepage "https://www.intra2net.com/en/developer/libftdi/"
  url "https://www.intra2net.com/en/developer/libftdi/download/libftdi1-1.5.tar.bz2"
  sha256 "7c7091e9c86196148bd41177b4590dccb1510bfe6cea5bf7407ff194482eb049"
  license "LGPL-2.1-only"

  bottle do
    sha256 "21f34f59a9661a68c5f15b7aa025e7650a0c0ccbed2857828166cb51d186d6cd" => :tiger_altivec
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "confuse"
  depends_on "libusb"

  # Patch to fix pkg-config flags issue. Homebrew/homebrew-core#71623
  # http://developer.intra2net.com/git/?p=libftdi;a=commit;h=cdb28383402d248dbc6062f4391b038375c52385
  patch do
    url "http://developer.intra2net.com/git/?p=libftdi;a=patch;h=cdb28383402d248dbc6062f4391b038375c52385;hp=5c2c58e03ea999534e8cb64906c8ae8b15536c30"
    sha256 "db4c3e558e0788db00dcec37929f7da2c4ad684791977445d8516cc3e134a3c4"
  end

  def install
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    mkdir "libftdi-build" do
      args = std_cmake_args
      args << "-DPYTHON_BINDINGS=OFF"
      args << "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
      args << "-DFTDIPP=OFF"
      # gcc-4.2 does not find stdarg.h if the sysroot is set to an SDK
      args << "-DCMAKE_OSX_SYSROOT=/" if MacOS.version < :leopard

      system "cmake", "..", *args
      system "make", "install"
      pkgshare.install "../examples"
      (pkgshare/"examples/bin").install Dir["examples/*"] \
                                        - Dir["examples/{CMake*,Makefile,*.cmake}"]
    end
  end

  test do
    system pkgshare/"examples/bin/find_all"
  end
end
