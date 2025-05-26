class Frotz < Formula
  desc "Interpreter for Infocom games and other Z-machine games"
  homepage "https://davidgriffith.gitlab.io/frotz/"
  url "https://gitlab.com/DavidGriffith/frotz/-/archive/2.44/frotz-2.44.tar.gz"
  sha256 "dbb5eb3bc95275dcb984c4bdbaea58bc1f1b085b20092ce6e86d9f0bf3ba858f"

  depends_on "pkg-config" => :build

  resource "testdata" do
    url "https://gitlab.com/DavidGriffith/frotz/-/raw/2.53/src/test/etude/etude.z5"
    sha256 "bfa2ef69f2f5ce3796b96f9b073676902e971aedb3ba690b8835bb1fb0daface"
  end

  def install
    inreplace "Makefile", "PREFIX = /usr/local", "PREFIX = #{prefix}"
    inreplace "Makefile", "MAN_PREFIX = $(PREFIX)", "MAN_PREFIX = #{man}/.."
    system "make", "all"
    system "make", "install"
    system "make", "install_dumb"
  end

  test do
    resource("testdata").stage do
      assert_match "TerpEtude", pipe_output("#{bin}/dfrotz etude.z5", ".")
    end
    assert_match "FROTZ", shell_output("#{bin}/frotz | head -n 1").strip
    assert_match "FROTZ", shell_output("#{bin}/dfrotz | head -n 1").strip
  end
end
