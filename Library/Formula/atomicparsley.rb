class Atomicparsley < Formula
  desc "MPEG-4 command-line tool"
  homepage "https://bitbucket.org/wez/atomicparsley/overview/"
  url "https://bitbucket.org/dinkypumpkin/atomicparsley/downloads/atomicparsley-0.9.6.tar.bz2"
  sha256 "49187a5215520be4f732977657b88b2cf9203998299f238067ce38f948941562"


  head "https://bitbucket.org/wez/atomicparsley", :using => :hg

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-universal"
    system "make", "install"
  end
end
