class Libcoap < Formula
  desc "Lightweight application-protocol for resource-constrained devices"
  homepage "http://libcoap.sourceforge.net"
  url "https://downloads.sourceforge.net/project/libcoap/coap-18/libcoap-4.1.1.tar.gz"
  sha256 "20cd0f58434480aa7e97e93a66ffef4076921de9687b14bd29fbbf18621bd394"


  depends_on "doxygen" => :build

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"

    include.install "coap.h"
    lib.install "libcoap.a"
    bin.install "examples/coap-server", "examples/coap-client"
  end
end
