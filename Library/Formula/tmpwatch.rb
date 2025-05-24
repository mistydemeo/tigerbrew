class Tmpwatch < Formula
  desc "Find and remove files not accessed in a specified time"
  homepage "https://fedorahosted.org/tmpwatch/"
  url "https://fedorahosted.org/releases/t/m/tmpwatch/tmpwatch-2.11.tar.bz2"
  sha256 "93168112b2515bc4c7117e8113b8d91e06b79550d2194d62a0c174fe6c2aa8d4"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    touch %w[a b c]
    ten_minutes_ago = Time.new - 600
    File.utime(ten_minutes_ago, ten_minutes_ago, "a")
    system "#{sbin}/tmpwatch", "2m", testpath
    assert_equal %w[b c], Dir["*"]
  end
end
