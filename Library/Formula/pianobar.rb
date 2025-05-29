class Pianobar < Formula
  desc "Command-line player for http://pandora.com"
  homepage "https://github.com/PromyLOPh/pianobar/"
  url "http://6xq.net/projects/pianobar/pianobar-2014.09.28.tar.bz2"
  sha256 "6bd10218ad5d68c4c761e02c729627d2581b4a6db559190e7e52dc5df177e68f"
  head "https://github.com/PromyLOPh/pianobar.git"

  bottle do
    cellar :any
    sha256 "ef2d4e3cb2478c1efa40986b53d6dbde50d147fa53e726f5a5145697c0bbbc3e" => :tiger_altivec
    sha256 "bf1d6fe5f2785d51f7dad6fdb080d840548298eb467bac014b5e7ed10073f5d3" => :leopard_g3
    sha256 "d0923378f486ead741c0eeaebb2f1c7d3b661975cc4a6a863d122f0d6b11c240" => :leopard_altivec
  end

  depends_on "make" => :build if MacOS.version < :leopard
  depends_on "pkg-config" => :build
  depends_on "libao"
  depends_on "mad"
  depends_on "faad2"
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "json-c"
  depends_on "ffmpeg"

  fails_with :llvm do
    build 2334
    cause "Reports of this not compiling on Xcode 4"
  end

  def install
    # Discard Homebrew's CFLAGS as Pianobar reportedly doesn't like them
    ENV["CFLAGS"] = "-O2 -DNDEBUG " +
                    # Or it doesn't build at all
                    "-std=c99 " +
                    # build if we aren't /usr/local'
                    "#{ENV.cppflags} #{ENV.ldflags}"
    system make_path, "PREFIX=#{prefix}"
    system make_path, "install", "PREFIX=#{prefix}"

    prefix.install "contrib"
  end
end
