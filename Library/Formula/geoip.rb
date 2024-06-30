class Geoip < Formula
  desc "GeoIP databases in a number of formats"
  homepage "https://github.com/maxmind/geoip-api-c"
  url "https://github.com/maxmind/geoip-api-c/releases/download/v1.6.12/GeoIP-1.6.12.tar.gz"
  sha256 "1dfb748003c5e4b7fd56ba8c4cd786633d5d6f409547584f6910398389636f80"
  license "LGPL-2.1-or-later"

  bottle do
    cellar :any
  end

  depends_on "geoipupdate" => :optional

  option :universal

  resource "database" do
    url "https://src.fedoraproject.org/lookaside/pkgs/GeoIP/GeoIP.dat.gz/4bc1e8280fe2db0adc3fe48663b8926e/GeoIP.dat.gz"
    sha256 "7fd7e4829aaaae2677a7975eeecd170134195e5b7e6fc7d30bf3caf34db41bcd"
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--datadir=#{var}",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  def post_install
    geoip_data = Pathname.new "#{var}/GeoIP"
    geoip_data.mkpath

    resource("database").stage do
      cp "GeoIP.dat", "#{geoip_data}/GeoIP.dat"
    end
  end

  test do
    output = shell_output("#{bin}/geoiplookup 8.8.8.8")
    assert_match "GeoIP Country Edition: US, United States", output
  end
end
