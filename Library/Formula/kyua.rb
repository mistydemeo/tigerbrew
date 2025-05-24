class Kyua < Formula
  desc "Testing framework for infrastructure software"
  homepage "https://github.com/jmmv/kyua"
  url "https://github.com/jmmv/kyua/releases/download/kyua-0.11/kyua-0.11.tar.gz"
  sha256 "2b8b64a458b642df75086eeb73e8073d105b8d9cff04c9b1a905b68bc8502560"


  depends_on "atf"
  depends_on "lutok"
  depends_on "pkg-config" => :build
  depends_on "lua"
  depends_on "sqlite"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    ENV.j1
    system "make", "install"
  end
end
