class Ntp < Formula
  desc "Network Time Protocol (NTP) Distribution"
  homepage "https://www.ntp.org"
  url "https://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p17.tar.gz"
  version "4.2.8p17"
  sha256 "103dd272e6a66c5b8df07dce5e9a02555fcd6f1397bdfb782237328e89d3a866"
  license all_of: ["BSD-2-Clause", "NTP"]

  bottle do
    sha256 "328717f558bfb5137571df39fbd4402b602019bc14ee891bd86e026ec18fdcdf" => :tiger_altivec
  end

  depends_on "openssl"

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-openssl-libdir=#{Formula["openssl"].lib}
      --with-openssl-incdir=#{Formula["openssl"].include}
      --with-net-snmp-config=no
    ]

    system "./configure", *args
    ldflags = "-lresolv -undefined dynamic_lookup"
    system "make", "install", "LDADD_LIBNTP=#{ldflags}"
  end

  test do
    assert_match "step time server ", shell_output("#{sbin}/ntpdate -bq pool.ntp.org")
  end
end
