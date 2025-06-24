class Libzip < Formula
  desc "C library for reading, creating, and modifying zip archives"
  homepage "http://www.nih.at/libzip/"
  url "http://www.nih.at/libzip/libzip-0.11.2.tar.gz"
  sha256 "83db1fb43a961ff7d1d1b50e1c6bea09c67e6af867686d1fc92ecb7dc6cf98d5"


  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}",
                          "--mandir=#{man}",
                          "CXX=#{ENV.cxx}",
                          "CXXFLAGS=#{ENV.cflags}"
    system "make", "install"
  end

  test do
    touch "file1"
    system "zip", "file1.zip", "file1"
    touch "file2"
    system "zip", "file2.zip", "file1", "file2"
    assert_match /\+.*file2/, shell_output("#{bin}/zipcmp -v file1.zip file2.zip", 1)
  end
end
