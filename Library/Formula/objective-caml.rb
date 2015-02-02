class ObjectiveCaml < Formula
  homepage "http://ocaml.org"
  url "http://caml.inria.fr/pub/distrib/ocaml-4.02/ocaml-4.02.1.tar.gz"
  sha1 "6af8c67f2badece81d8e1d1ce70568a16e42313e"
  revision 2

  head "http://caml.inria.fr/svn/ocaml/trunk", :using => :svn

  option "with-x11", "Install with the Graphics module"

  depends_on :ld64
  depends_on :x11 => :optional

  bottle do
    sha1 "d3f09d213f57210e4a9e1b482ca8e2fdf39d5836" => :yosemite
    sha1 "5fb1b744f2e8efa49d00d5bcf01547db2b3d32c4" => :mavericks
    sha1 "e551c48370a3b5a43d843510b81032fccc2197ec" => :mountain_lion
  end

  # Removes -no_compact_unwind, which wasn't available in Leopard's ld
  patch :p1 do
    url "https://gist.githubusercontent.com/anonymous/1f3cf8cd60be707ab3b9/raw/2d46e20089892c2a87c04627733c6b7bbb1004fc/-"
    sha1 "1576b98b1b175e4299193e357cddd81422545b6f"
  end if MacOS.version < :snow_leopard

  def install
    args = %W[
      --prefix #{HOMEBREW_PREFIX}
      --mandir #{man}
      -cc #{ENV.cc}
      -with-debug-runtime
    ]
    args << "-aspp" << "#{ENV.cc} -c"
    args << "-no-graph" if build.without? "x11"

    ENV.deparallelize # Builds are not parallel-safe, esp. with many cores
    system "./configure", *args
    system "make", "world"
    system "make", "opt"
    system "make", "opt.opt"
    system "make", "PREFIX=#{prefix}", "install"
  end
end
