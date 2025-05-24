class Libmikmod < Formula
  desc "Portable sound library"
  homepage "http://mikmod.shlomifish.org"
  url "https://downloads.sourceforge.net/project/mikmod/libmikmod/3.3.7/libmikmod-3.3.7.tar.gz"
  sha256 "4cf41040a9af99cb960580210ba900c0a519f73ab97b503c780e82428b9bd9a2"


  option "with-debug", "Enable debugging symbols"

  def install
    ENV.O2 if build.with? "debug"

    # OSX has CoreAudio, but ALSA is not for this OS nor is SAM9407 nor ULTRA.
    args = %W[
      --prefix=#{prefix}
      --disable-alsa
      --disable-sam9407
      --disable-ultra
    ]
    args << "--with-debug" if build.with? "debug"
    mkdir "macbuild" do
      system "../configure", *args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/libmikmod-config", "--version"
  end
end
