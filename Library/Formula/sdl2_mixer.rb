class Sdl2Mixer < Formula
  desc "Sample multi-channel audio mixer library"
  homepage "https://www.libsdl.org/projects/SDL_mixer/"
  url "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-2.0.0.tar.gz"
  sha256 "a8ce0e161793791adeff258ca6214267fdd41b3c073d2581cd5265c8646f725b"


  head "https://hg.libsdl.org/SDL_mixer", :using => :hg

  option :universal

  depends_on "pkg-config" => :build
  depends_on "sdl2"
  depends_on "flac" => :optional
  depends_on "fluid-synth" => :optional
  depends_on "smpeg2" => :optional
  depends_on "libmikmod" => :optional
  depends_on "libvorbis" => :optional

  def install
    unless build.head?
      # work around a bug where an indentifier was misnamed in a OS X + PPC-only section of sdl2_mixer's source
      inreplace "native_midi/native_midi_macosx.c", "MusicSequenceLoadSMFData(song->sequence", "MusicSequenceLoadSMFData(retval->sequence"
    end

    ENV.universal_binary if build.universal?
    inreplace "SDL2_mixer.pc.in", "@prefix@", HOMEBREW_PREFIX

    ENV["SMPEG_CONFIG"] = "#{Formula["smpeg2"].bin}/smpeg2-config" if build.with? "smpeg2"

    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make", "install"
  end
end
