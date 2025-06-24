class Camlp5 < Formula
  desc "Camlp5 is a preprocessor and pretty-printer for OCaml"
  homepage "http://camlp5.gforge.inria.fr/"
  url "http://camlp5.gforge.inria.fr/distrib/src/camlp5-6.14.tgz"
  sha256 "09f9ed12893d2ec39c88106af2306865c966096bedce0250f2fe52b67d2480e2"


  depends_on :ld64 # uses -no_compact_unwind
  depends_on "ocaml"

  option "strict", "Compile in strict mode"

  def install
    if build.include? "strict"
      strictness = "-strict"
    else
      strictness = "-transitional"
    end

    system "./configure", "-prefix", prefix, "-mandir", man, strictness
    # this build fails if jobs are parallelized
    ENV.deparallelize
    system "make", "world.opt"
    system "make", "install"
  end
end
