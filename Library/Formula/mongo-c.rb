class MongoC < Formula
  desc "Official C driver for MongoDB"
  homepage "https://docs.mongodb.org/ecosystem/drivers/c/"
  url "https://github.com/mongodb/mongo-c-driver/releases/download/1.1.6/mongo-c-driver-1.1.6.tar.gz"
  sha256 "231d0d038c848e8871fa03b70f74284dd8481734eac2bf05fb240e94c9279130"


  head do
    url "https://github.com/mongodb/mongo-c-driver.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libbson"
  depends_on "openssl" => :recommended

  def install
    # --enable-sasl=no: https://jira.mongodb.org/browse/CDRIVER-447
    args = ["--prefix=#{prefix}", "--enable-sasl=no"]

    if build.head?
      system "./autogen.sh"
    end

    if build.with?("openssl")
      args << "--enable-ssl=yes"
    else
      args << "--enable-ssl=no"
    end

    system "./configure", *args
    system "make", "install"
  end
end
