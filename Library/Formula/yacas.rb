class Yacas < Formula
  desc "General purpose computer algebra system"
  homepage "http://yacas.sourceforge.net"
  url "https://downloads.sourceforge.net/project/yacas/yacas-source/1.3/yacas-1.3.4.tar.gz"
  sha256 "18482f22d6a8336e9ebfda3bec045da70db2da68ae02f32987928a3c67284233"


  option "with-server", "Build the network server version"

  def install
    args = ["--disable-silent-rules",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}"
           ]

    args << "--enable-server" if build.with? "server"

    system "./configure", *args
    system "make", "install"
    system "make", "test"
  end

  test do
    system "#{bin}/yacas", "--version"
  end
end
