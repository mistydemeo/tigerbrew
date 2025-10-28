class Libdnet < Formula
  desc "Portable low-level networking library"
  homepage "https://code.google.com/p/libdnet/"
  url "https://github.com/ofalk/libdnet/archive/refs/tags/libdnet-1.18.0.tar.gz"
  sha256 "a4a82275c7d83b85b1daac6ebac9461352731922161f1dcdcccd46c318f583c9"

  bottle do
    cellar :any
    sha256 "c75150ec4b846f6b726839dae1d20d275cca3061f2be19cfc341f66b564b286d" => :tiger_altivec
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "check" => :build
  depends_on "libtool" => :build
  depends_on "cython" => :build

  def install
    # autoreconf to get '.dylib' extension on shared lib
    ENV.append_path "ACLOCAL_PATH", "config"
    system "autoreconf", "-ivf"
    ENV.prepend_path "PYTHONPATH", "#{Formula["cython"].opt_libexec}/lib/python3.10/site-packages"

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
    ]
    system "./configure", *args
    system "make", "install"
  end
end
