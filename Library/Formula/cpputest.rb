class Cpputest < Formula
  desc "C /C++ based unit xUnit test framework"
  homepage "http://www.cpputest.org/"
  url "https://github.com/cpputest/cpputest/releases/download/3.7.2/cpputest-3.7.2.tar.gz"
  sha256 "8c5d00be3a08ea580e51e5cfe26f05d05c6bf546206ff67dbb3757d48c109653"


  head do
    url "https://github.com/cpputest/cpputest.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end
end
