class Rsnapshot < Formula
  desc "File system snapshot utility (based on rsync)"
  homepage "http://rsnapshot.org"
  url "http://rsnapshot.org/downloads/rsnapshot-1.4.1.tar.gz"
  sha256 "fb4a1129a7d3805c41749fd0494debfe2ca2341eba0f8b50e4f54985efe448e8"

  head "https://github.com/DrHyde/rsnapshot.git"


  def install
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make", "install"
  end
end
