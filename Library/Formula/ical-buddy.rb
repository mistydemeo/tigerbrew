class IcalBuddy < Formula
  desc "Get events and tasks from the OS X calendar database"
  homepage "http://hasseg.org/icalBuddy/"
  head "https://github.com/ali-rantakari/icalBuddy.git"
  url "https://github.com/ali-rantakari/icalBuddy/archive/v1.8.10.tar.gz"
  sha256 "3fb50cffd305ed6ac0ebb479e04ff254074ee5e4b1a1c279bd24c3cc56bcccb0"


  def install
    args = %W[icalBuddy icalBuddy.1 icalBuddyLocalization.1
              icalBuddyConfig.1 COMPILER=#{ENV.cc}]
    system "make", *args
    bin.install "icalBuddy"
    man1.install Dir["*.1"]
  end
end
