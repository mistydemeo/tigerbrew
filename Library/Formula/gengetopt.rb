class Gengetopt < Formula
  desc "Generate C code to parse command-line arguments via getopt_long"
  homepage "https://www.gnu.org/software/gengetopt/"
  url "http://ftpmirror.gnu.org/gengetopt/gengetopt-2.23.tar.xz"
  mirror "https://ftp.gnu.org/gnu/gengetopt/gengetopt-2.23.tar.xz"
  sha256 "b941aec9011864978dd7fdeb052b1943535824169d2aa2b0e7eae9ab807584ac"

  bottle do
    sha256 "156ab4e381116412f81e438eb9768d4ada3efe672f16e65c42ea9a2bc6ed287b" => :tiger_altivec
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"

    ENV.deparallelize
    system "make", "install"
  end

  test do
    ggo = <<-EOS.undent
      package "homebrew"
      version "0.9.5"
      purpose "The missing package manager for OS X"

      option "verbose" v "be verbose"
    EOS

    pipe_output("#{bin}/gengetopt --file-name=test", ggo, 0)
    assert File.exist? "test.h"
    assert File.exist? "test.c"
    assert_match(/verbose_given/, File.read("test.h"))
  end
end
