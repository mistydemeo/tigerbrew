class Timidity < Formula
  desc "Software synthesizer"
  homepage "http://timidity.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/timidity/TiMidity++/TiMidity++-2.14.0/TiMidity++-2.14.0.tar.bz2"
  sha256 "f97fb643f049e9c2e5ef5b034ea9eeb582f0175dce37bc5df843cc85090f6476"


  option "without-darwin", "Build without Darwin CoreAudio support"
  option "without-freepats", "Build without the Freepats instrument patches from http://freepats.zenvoid.org/"

  depends_on "libogg" => :recommended
  depends_on "libvorbis" => :recommended
  depends_on "flac" => :recommended
  depends_on "speex" => :recommended
  depends_on "libao" => :recommended

  resource "freepats" do
    url "http://freepats.zenvoid.org/freepats-20060219.zip"
    sha256 "532048a5777aea717effabf19a35551d3fcc23b1ad6edd92f5de1d64600acd48"
  end

  def install
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--mandir=#{man}"
           ]

    formats = []
    formats << "darwin" if build.with? "darwin"
    formats << "vorbis" if build.with?("libogg") && build.with?("libvorbis")
    formats << "flac" if build.with? "flac"
    formats << "speex" if build.with? "speex"
    formats << "ao" if build.with? "libao"

    if formats.any?
      args << "--enable-audio=" + formats.join(",")
    end

    system "./configure", *args
    system "make", "install"

    if build.with? "freepats"
      (share/"freepats").install resource("freepats")
      (share/"timidity").install_symlink share/"freepats/Tone_000",
                                         share/"freepats/Drum_000",
                                         share/"freepats/freepats.cfg" => "timidity.cfg"
    end
  end

  test do
    system "#{bin}/timidity"
  end
end
