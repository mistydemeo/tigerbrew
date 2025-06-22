class Faad2 < Formula
  desc "ISO AAC audio decoder"
  homepage "https://faac.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/faac/faad2-src/faad2-2.7/faad2-2.7.tar.bz2"
  sha256 "14561b5d6bc457e825bfd3921ae50a6648f377a9396eaf16d4b057b39a3f63b5"

  # unknown flag: -compatibility_version
  depends_on :ld64

  bottle do
    cellar :any
    sha256 "c64b6d56f3464fe198697cc666c717c897f0c3b5e079e0d2fbb641d525950bfe" => :tiger_altivec
    sha256 "9824e92e089976d8cbca8f48dae86183dd0573bf82b495b32fb954b7fdb26322" => :leopard_g3
    sha256 "0ba8b1ba5235248ae43646e11a70b8365e09141fc38b18556fc3af52440fe4ef" => :leopard_altivec
  end

  def install
    # libtool ignores our LDFLAGS, so it won't find ld64 in stdenv without extra help
    if MacOS.version < :leopard
      inreplace "ltmain.sh",
                "${wl}-compatibility_version ${wl}$minor_current ${wl}-current_version ${wl}$minor_current.$revision",
                "-B#{Formula["ld64"].opt_bin}/ ${wl}-compatibility_version ${wl}$minor_current ${wl}-current_version ${wl}$minor_current.$revision"
    end

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    man1.install man+"manm/faad.man" => "faad.1"
  end
end
