class Ii < Formula
  desc "Minimalist IRC client"
  homepage "http://tools.suckless.org/ii"
  url "http://dl.suckless.org/tools/ii-1.7.tar.gz"
  sha256 "3a72ac6606d5560b625c062c71f135820e2214fed098e6d624fc40632dc7cc9c"


  head "http://git.suckless.org/ii", :using => :git

  def install
    inreplace "config.mk" do |s|
      s.gsub! "/usr/local", prefix
      s.gsub! "cc", ENV.cc
    end
    system "make", "install"
  end
end
