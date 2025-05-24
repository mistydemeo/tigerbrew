class Getxbook < Formula
  desc "Tools to download ebooks from various sources"
  homepage "https://njw.name/getxbook"
  url "https://njw.name/getxbook/getxbook-1.2.tar.xz"
  sha256 "7a4b1636ecb6dace814b818d9ff6a68167799b81ac6fc4dca1485efd48cf1c46"


  option "with-gui", "Build the GUI"

  depends_on "openssl"
  depends_on "tcl-tk" if build.with? "gui"

  def install
    args = %W[CC=#{ENV.cc} PREFIX=#{prefix}]
    args << "install" if build.with?("gui")

    system "make", *args
    bin.install "getgbook", "getabook", "getbnbook"
  end

  test do
    assert_match "getgbook #{version}", shell_output("#{bin}/getgbook", 1)
  end
end
