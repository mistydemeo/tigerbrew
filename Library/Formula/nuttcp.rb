class Nuttcp < Formula
  desc "Network performance measurement tool"
  homepage "http://www.nuttcp.net/nuttcp"
  url "http://www.nuttcp.net/nuttcp/nuttcp-6.1.2.tar.bz2"
  sha256 "054e96d9d68fe917df6f25fab15c7755bdd480f6420d7d48d9194a1a52378169"


  def install
    system "make", "APP=nuttcp",
           "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}"
    bin.install "nuttcp"
    man8.install "nuttcp.cat" => "nuttcp.8"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nuttcp -V")
  end
end
