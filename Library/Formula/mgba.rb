class Mgba < Formula
  desc "Game Boy Advance emulator"
  homepage "https://mgba.io/"
  url "https://github.com/mgba-emu/mgba/archive/0.6.3.tar.gz"
  sha256 "35c8906c01206adae714fee9c2bc39698c514a4adb32c9c4a5a3fa58b2d10f9a"
  head "https://github.com/mgba-emu/mgba.git"

  depends_on :ld64 # fixes a linktime error on Tiger
  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libepoxy"
  depends_on "libpng"
  depends_on "libzip"
  depends_on "sdl2"

  # error: stdarg.h: No such file or directory
  fails_with :gcc if MacOS.version == :tiger

  def install
    # Qt is still broken on 10.4, so build with it off by default.
    # FFmpeg introduces a VideoDecodeAcceleration framework requirement,
    # which isn't available on older OS Xs.
    # Imagemagick fails to link due to some strange path lookup issues.
    # The Sqlite feature isn't exposed in the SDL build, so no reason to enable it.
    args = ["-DBUILD_QT=OFF", "-DUSE_FFMPEG=OFF", "-DUSE_MAGICK=OFF", "-DUSE_SQLITE3=OFF"]

    # GCC 4.0 and 4.2 don't support -flto
    # The buildsystem will detect this in the next stable release.
    # GCC also doesn't enable LTO on Tiger.
    if MacOS.version < :leopard || [:gcc, :gcc_4_0].include?(ENV.compiler)
      args << "-DBUILD_LTO=OFF"
    end

    system "cmake", ".", *(std_cmake_args + args)
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mGBA --version")
  end
end
