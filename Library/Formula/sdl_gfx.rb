class SdlGfx < Formula
  desc "Graphics drawing primitives and other support functions"
  homepage "https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/"
  url "http://www.ferzkopp.net/Software/SDL_gfx-2.0/SDL_gfx-2.0.24.tar.gz"
  sha256 "30ad38c3e17586e5212ce4a43955adf26463e69a24bb241f152493da28d59118"

  bottle do
    cellar :any
    revision 1
    sha256 "202f917c2ceef69a4ec07de2a9a61e8def2c9d8499cc15633c5efbb3c4db914c" => :el_capitan
    sha1 "6c70b7a9048bc066ecbb3c037c3a1a0fe2d3166a" => :yosemite
    sha1 "364758460ad6f2cfc83c58d5fc8e793688cd9862" => :mavericks
    sha1 "342e8a64a908f0e39ba6a1d8318ed111679067a1" => :mountain_lion
  end

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
