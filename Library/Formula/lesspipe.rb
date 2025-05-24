class Lesspipe < Formula
  desc "Input filter for the pager less"
  homepage "https://www-zeuthen.desy.de/~friebel/unix/lesspipe.html"
  url "https://downloads.sourceforge.net/project/lesspipe/lesspipe/1.82/lesspipe-1.82.tar.gz"
  sha256 "3fd345b15d46cc8fb0fb1d625bf8d881b0637abc34d15df45243fd4e5a8f4241"


  option "with-syntax-highlighting", "Build with syntax highlighting"

  deprecated_option "syntax-highlighting" => "with-syntax-highlighting"

  def install
    if build.with? "syntax-highlighting"
      inreplace "configure", %q($ifsyntax = "\L$ifsyntax";), %q($ifsyntax = "\Ly";)
    end

    system "./configure", "--prefix=#{prefix}", "--yes"
    man1.mkpath
    system "make", "install"
  end

  test do
    touch "file1.txt"
    touch "file2.txt"
    system "tar", "-cvzf", "homebrew.tar.gz", "file1.txt", "file2.txt"

    assert File.exist?("homebrew.tar.gz")
    assert_match /file2.txt/, shell_output("tar tvzf homebrew.tar.gz | #{bin}/tarcolor")
  end
end
