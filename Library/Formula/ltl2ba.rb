class Ltl2ba < Formula
  desc "Translate LTL formulae to Buchi automata"
  homepage "http://www.lsv.ens-cachan.fr/~gastin/ltl2ba/"
  url "http://www.lsv.ens-cachan.fr/~gastin/ltl2ba/ltl2ba-1.2b1.tar.gz"
  sha256 "950f304c364ffb567a4fba9b88f1853087c0dcf57161870b6314493fddb492b8"


  def install
    system "make"
    bin.install "ltl2ba"
  end
end
