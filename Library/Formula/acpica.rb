class Acpica < Formula
  desc "OS-independent implementation of the ACPI specification"
  homepage "https://www.acpica.org/"
  head "https://github.com/acpica/acpica.git"
  url "https://acpica.org/sites/acpica/files/acpica-unix2-20150717.tar.gz"
  sha256 "dd60f846ad8393d89d2cbadf362c6547c5e53405f5ee51097c90db3636f79e0a"


  def install
    ENV.deparallelize
    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/acpihelp", "-u"
  end
end
