# OCaml does not preserve binary compatibility across compiler releases,
# so when updating it you should ensure that all dependent packages are
# also updated by incrementing their revisions.
#
# Specific packages to pay attention to include:
# - camlp4
# - opam
#
# Applications that really shouldn't break on a compiler update are:
# - mldonkey
# - coq
# - coccinelle
# - unison
class Ocaml < Formula
  desc "General purpose programming language in the ML family"
  homepage "https://ocaml.org/"
  head "http://caml.inria.fr/svn/ocaml/trunk", :using => :svn

  stable do
    url "http://caml.inria.fr/pub/distrib/ocaml-4.02/ocaml-4.02.3.tar.gz"
    sha256 "928fb5f64f4e141980ba567ff57b62d8dc7b951b58be9590ffb1be2172887a72"
  end


  option "with-x11", "Install with the Graphics module"

  depends_on :ld64
  depends_on :x11 => :optional

  # Removes -no_compact_unwind, which wasn't available in Leopard's ld
  patch :p1 do
    url "https://gist.githubusercontent.com/anonymous/1f3cf8cd60be707ab3b9/raw/2d46e20089892c2a87c04627733c6b7bbb1004fc/-"
    sha1 "1576b98b1b175e4299193e357cddd81422545b6f"
  end if MacOS.version < :snow_leopard

  def install
    ENV.deparallelize # Builds are not parallel-safe, esp. with many cores

    # the ./configure in this package is NOT a GNU autoconf script!
    args = ["-prefix", "#{HOMEBREW_PREFIX}", "-with-debug-runtime", "-mandir", man]
    args << "-no-graph" if build.without? "x11"
    system "./configure", *args

    system "make", "world.opt"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match "val x : int = 1", shell_output("echo 'let x = 1 ;;' | ocaml 2>&1")
    assert_match "#{HOMEBREW_PREFIX}", shell_output("ocamlc -where")
  end
end
