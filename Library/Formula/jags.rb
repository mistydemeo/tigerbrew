class Jags < Formula
  desc "Just Another Gibbs Sampler for Bayesian MCMC simulation"
  homepage "http://mcmc-jags.sourceforge.net"
  url "https://downloads.sourceforge.net/project/mcmc-jags/JAGS/3.x/Source/JAGS-3.4.0.tar.gz"
  sha256 "2beaa9a2672c2c95efc55ffa4c8b597a872f20232373daebd17ad539d3d7d82b"

  revision 1

  depends_on :fortran

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
