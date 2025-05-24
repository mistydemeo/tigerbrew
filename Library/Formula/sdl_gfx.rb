class SdlGfx < Formula
  desc "Graphics drawing primitives and other support functions"
  homepage "http://www.ferzkopp.net/joomla/content/view/19/14/"
  url "http://www.ferzkopp.net/Software/SDL_gfx-2.0/SDL_gfx-2.0.24.tar.gz"
  sha256 "30ad38c3e17586e5212ce4a43955adf26463e69a24bb241f152493da28d59118"


  depends_on "sdl"

  option :universal

  def install
    ENV.universal_binary if build.universal?
    args = %W[--disable-dependency-tracking
              --prefix=#{prefix}
              --disable-sdltest]
    args << "--disable-mmx" unless Hardware::CPU.type == :intel

    system "./configure", *args
    system "make", "install"
  end
end
