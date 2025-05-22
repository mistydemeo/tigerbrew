class Ipbt < Formula
  desc "Program for recording a UNIX terminal session"
  homepage "http://www.chiark.greenend.org.uk/~sgtatham/ipbt/"
  url "http://www.chiark.greenend.org.uk/~sgtatham/ipbt/ipbt-20141026.2197432.tar.gz"
  sha256 "151da94da378cc88e979df8eb5f9a05c4e663bd1299c191d24c10128bae879b0"


  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    system "#{bin}/ipbt"
  end
end
