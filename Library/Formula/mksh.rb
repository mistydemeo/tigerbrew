class Mksh < Formula
  desc "MirBSD Korn Shell"
  homepage "https://mirbsd.org/mksh.htm"
  url "http://www.mirbsd.org/MirOS/dist/mir/mksh/mksh-R59c.tgz"
  mirror "http://pub.allbsd.org/MirOS/dist/mir/mksh/mksh-R59c.tgz"
  sha256 "77ae1665a337f1c48c61d6b961db3e52119b38e58884d1c89684af31f87bc506"

  bottle do
    cellar :any_skip_relocation
    sha256 "78d0d6429a7861139619e81aae481991c5dbf874af27c2bac0ab7aee5b2f89ea" => :tiger_altivec
  end

  def install
    system "sh", "./Build.sh", "-r"
    system "./test.sh"
    system "sh", "./FAQ2HTML.sh"
    bin.install "mksh"
    doc.install "FAQ.htm"
    man1.install "mksh.1"
    pkgshare.install "dot.mkshrc"
  end

  def caveats; <<-EOS.undent
    To allow using mksh as a login shell, run this as root:
        echo #{HOMEBREW_PREFIX}/bin/mksh >> /etc/shells
    Then, any user may run `chsh` to change their shell.
    EOS
  end

  test do
    assert_equal "honk",
                 shell_output("mksh -c 'echo honk'").chomp
  end
end
