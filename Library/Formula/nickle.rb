class Nickle < Formula
  desc "Desk calculator language"
  homepage "https://www.nickle.org/"
  url "http://www.nickle.org/release/nickle-2.77.tar.gz"
  sha256 "a35e7ac9a3aa41625034db5c809effc208edd2af6a4adf3f4776fe60d9911166"
  revision 1

  depends_on "readline"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_equal "4", shell_output("#{bin}/nickle -e '2+2'").chomp
  end
end
