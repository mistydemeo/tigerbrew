class Malaga < Formula
  desc "Grammar development environment for natural languages"
  homepage "http://home.arcor.de/bjoern-beutel/malaga/"
  url "https://launchpad.net/ubuntu/+archive/primary/+files/malaga_7.12.orig.tar.gz"
  sha256 "8811e5feaae03e1b6e3008116fdc7471a53b6c0c5036751c637b15058f855ace"


  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "gtk+" => :optional

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    system "make", "install"
  end
end
