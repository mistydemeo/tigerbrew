class Libcroco < Formula
  desc "CSS parsing and manipulation toolkit for GNOME"
  homepage "http://www.linuxfromscratch.org/blfs/view/svn/general/libcroco.html"
  url "https://download.gnome.org/sources/libcroco/0.6/libcroco-0.6.8.tar.xz"
  sha256 "ea6e1b858c55219cefd7109756bff5bc1a774ba7a55f7d3ccd734d6b871b8570"

  bottle do
    cellar :any
    sha256 "578928a0a3b7c706ad3707b7bcd0470e044b1206752c814bfff62a9a7c607fc5" => :tiger_altivec
  end

  depends_on "pkg-config" => :build
  depends_on "intltool" => :build
  depends_on "glib"

  def install
    ENV.libxml2
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-Bsymbolic"
    system "make", "install"
  end

  test do
    (testpath/"test.css").write ".brew-pr { color: green }"
    assert_equal ".brew-pr {\n  color : green\n}",
      shell_output("#{bin}/csslint-0.6 test.css").chomp
  end
end
