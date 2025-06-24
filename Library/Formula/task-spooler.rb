class TaskSpooler < Formula
  desc "Batch system to run tasks one after another"
  homepage "http://vicerveza.homeunix.net/~viric/soft/ts/"
  url "http://vicerveza.homeunix.net/~viric/soft/ts/ts-0.7.5.tar.gz"
  sha256 "216d09dcfbae2f9bfea7582a71494172fe91c33d65499ea01b3bcac0600de96d"


  conflicts_with "moreutils",
    :because => "both install a 'ts' executable."

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end
end
