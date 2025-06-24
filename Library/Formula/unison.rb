class Unison < Formula
  desc "Unison file synchronizer"
  homepage "https://www.cis.upenn.edu/~bcpierce/unison/"
  url "https://www.seas.upenn.edu/~bcpierce/unison//download/releases/stable/unison-2.48.3.tar.gz"
  sha256 "f40d3cfbe82078d79328b51acab3e5179f844135260c2f4710525b9b45b15483"


  depends_on "ocaml" => :build

  def install
    ENV.j1
    ENV.delete "CFLAGS" # ocamlopt reads CFLAGS but doesn't understand common options
    ENV.delete "NAME" # https://github.com/Homebrew/homebrew/issues/28642
    system "make ./mkProjectInfo"
    system "make UISTYLE=text"
    bin.install "unison"
  end
end
