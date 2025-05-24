class Dash < Formula
  desc "POSIX-compliant descendant of NetBSD's ash (the Almquist SHell)"
  homepage "http://gondor.apana.org.au/~herbert/dash/"
  url "http://gondor.apana.org.au/~herbert/dash/files/dash-0.5.8.tar.gz"
  sha256 "c6db3a237747b02d20382a761397563d813b306c020ae28ce25a1c3915fac60f"


  head do
    url "https://git.kernel.org/pub/scm/utils/dash/dash.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  def install
    system "./autogen.sh" if build.head?

    system "./configure", "--prefix=#{prefix}",
                          "--with-libedit",
                          "--disable-dependency-tracking",
                          "--enable-fnmatch",
                          "--enable-glob"
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/dash", "-c", "echo Hello!"
  end
end
