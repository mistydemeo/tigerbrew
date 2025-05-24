class Intercal < Formula
  desc "Esoteric, parody programming language"
  homepage "http://catb.org/~esr/intercal/"
  url "http://catb.org/~esr/intercal/intercal-0.30.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/i/intercal/intercal_0.30.orig.tar.gz"
  sha256 "b38b62a61a3cb5b0d3ce9f2d09c97bd74796979d532615073025a7fff6be1715"

  head do
    url "git://thyrsus.com/repositories/intercal.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end


  def install
    if build.head?
      cd "buildaux" do
        system "./regenerate-build-system.sh"
      end
    end
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    etc.install Dir["etc/*"]
    share.install "pit"
  end

  test do
    system bin/"ick", share/"pit/beer.i"
  end
end
