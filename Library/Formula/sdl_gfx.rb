require 'formula'

class SdlGfx < Formula
  homepage 'http://www.ferzkopp.net/joomla/content/view/19/14/'
  url 'http://www.ferzkopp.net/Software/SDL_gfx-2.0/SDL_gfx-2.0.24.tar.gz'
  sha1 '34e8963188e4845557468a496066a8fa60d5f563'

  depends_on 'sdl'

  option :universal

  def install
    ENV.universal_binary if build.universal?
    args = %W[--disable-dependency-tracking
              --prefix=#{prefix}
              --disable-sdltest]
    args << "--disable-mmx" unless Hardware::CPU.type == :intel

    system "./configure", *args
    system "make install"
  end
end
