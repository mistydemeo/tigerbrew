class Axel < Formula
  desc "Light UNIX download accelerator"
  homepage "https://packages.debian.org/sid/axel"
  url "https://mirrors.kernel.org/debian/pool/main/a/axel/axel_2.4.orig.tar.gz"
  mirror "http://ftp.de.debian.org/debian/pool/main/a/axel/axel_2.4.orig.tar.gz"
  sha256 "359a57ab4e354bcb6075430d977c59d33eb3e2f1415a811948fa8ae657ca8036"


  def install
    system "./configure", "--prefix=#{prefix}", "--debug=0", "--i18n=0"
    system "make"
    system "make", "install"
  end

  test do
    filename = (testpath/"axel.tar.gz")
    system bin/"axel", "-o", "axel.tar.gz", stable.url
    filename.verify_checksum stable.checksum
    assert File.exist?("axel.tar.gz")
  end
end
