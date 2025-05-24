class Libdsk < Formula
  desc "Library for accessing discs and disc image files"
  homepage "http://www.seasip.info/Unix/LibDsk/"
  url "http://www.seasip.info/Unix/LibDsk/libdsk-1.3.8.tar.gz"
  sha256 "1472cb30534e3a1b3ac0c2e7e4a00a9c247955af5d407cb95c25391fb61e45d4"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
    (share+name+"doc").install Dir["doc/*.{html,txt,pdf}"]
  end
end
