class Gauche < Formula
  desc "R5RS Scheme implementation, developed to be a handy script interpreter"
  homepage "http://practical-scheme.net/gauche/"
  url "https://downloads.sourceforge.net/gauche/Gauche/Gauche-0.9.4.tgz"
  sha256 "7b18bcd70beaced1e004594be46c8cff95795318f6f5830dd2a8a700410fc149"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking",
                          "--enable-multibyte=utf-8"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    output = shell_output("gosh -V")
    assert_match /Gauche scheme shell, version #{version}/, output
  end
end
