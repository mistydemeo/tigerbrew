class Openconnect < Formula
  desc "Open client for Cisco AnyConnect VPN"
  homepage "http://www.infradead.org/openconnect.html"
  url "https://www.infradead.org/openconnect/download/openconnect-9.12.tar.gz"
  sha256 "a2bedce3aa4dfe75e36e407e48e8e8bc91d46def5335ac9564fbf91bd4b2413e"
  revision 1

  bottle do
    sha256 "4c379a66a6367ab6219a6a86bf4b429266af1c53ebfed5a1cc601fe3ff521878" => :tiger_altivec
  end

  head do
    url "git://git.infradead.org/users/dwmw2/openconnect.git", :shallow => false
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "openssl3"
  depends_on "oath-toolkit" => :optional
  depends_on "p11-kit"
  depends_on "stoken" => :optional
  depends_on "libxml2"
  depends_on "zlib"

  resource "vpnc-script" do
    url "https://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/78050150f712d96f81dcade1efe5d16d017e8471:/vpnc-script"
    sha256 "48cdff979f5f941e2740193c4ee2a90f55549908afcb1fcee64a66f8c0fec05f"
  end

  def install
    etc.install resource("vpnc-script")
    chmod 0755, "#{etc}/vpnc-script"

    if build.head?
      ENV["LIBTOOLIZE"] = "glibtoolize"
      system "./autogen.sh"
    end

    args = %W[
      --prefix=#{prefix}
      --sbindir=#{bin}
      --localstatedir=#{var}
      --with-vpnc-script=#{etc}/vpnc-script
      --without-gnutls
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match /anyconnect/, shell_output("#{bin}/openconnect -V")
  end
end
