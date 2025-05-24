class Remind < Formula
  desc "Sophisticated calendar and alarm"
  homepage "https://www.roaringpenguin.com/products/remind"
  url "https://www.roaringpenguin.com/files/download/remind-03.01.15.tar.gz"
  sha256 "8adab4c0b30a556c34223094c5c74779164d5f3b8be66b8039f44b577e678ec1"


  def install
    # Remove unnecessary sleeps when running on Apple
    inreplace "configure", "sleep 1", "true"
    inreplace "src/init.c" do |s|
      s.gsub! "sleep(5);", ""
      s.gsub! /rkrphgvba\(.\);/, ""
    end
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    reminders = "reminders"
    (testpath/reminders).write "ONCE 2015-01-01 Homebrew Test"
    assert_equal "Reminders for Thursday, 1st January, 2015:\n\nHomebrew Test\n\n", shell_output("#{bin}/remind #{reminders} 2015-01-01")
  end
end
