class Debianutils < Formula
  desc "Miscellaneous utilities specific to Debian"
  homepage "https://packages.debian.org/unstable/utils/debianutils"
  url "https://mirrors.kernel.org/debian/pool/main/d/debianutils/debianutils_4.5.1.tar.xz"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/d/debianutils/debianutils_4.5.1.tar.xz"
  sha256 "a531c23e0105fe01cfa928457a8343a1e947e2621b3cd4d05f4e9656020c63b7"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"

    # some commands are Debian Linux specific and we don't want them, so install specific tools
    bin.install "run-parts", "ischroot", "tempfile"
    man1.install "ischroot.1", "tempfile.1"
    man8.install "run-parts.8"
  end

  test do
    assert File.exist?(shell_output("#{bin}/tempfile -d #{Dir.pwd}").strip)
  end
end
