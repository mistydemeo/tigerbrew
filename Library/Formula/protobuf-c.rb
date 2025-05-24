class ProtobufC < Formula
  desc "Protocol buffers library"
  homepage "https://github.com/protobuf-c/protobuf-c"
  url "https://github.com/protobuf-c/protobuf-c/releases/download/v1.1.1/protobuf-c-1.1.1.tar.gz"
  sha256 "09c5bb187b7a8e86bc0ff860f7df86370be9e8661cdb99c1072dcdab0763562c"


  option :universal

  depends_on "pkg-config" => :build
  depends_on "protobuf"

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end
end
