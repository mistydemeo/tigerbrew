class Speex < Formula
  desc "Audio codec designed for speech"
  homepage "http://speex.org"
  url "http://downloads.us.xiph.org/releases/speex/speex-1.2rc1.tar.gz"
  sha256 "342f30dc57bd4a6dad41398365baaa690429660b10d866b7d508e8f1179cb7a6"


  depends_on "pkg-config" => :build
  depends_on "libogg" => :recommended

  def install
    ENV.j1
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
