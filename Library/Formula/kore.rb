class Kore < Formula
  desc "Web application framework for writing web APIs in C"
  homepage "https://kore.io/"
  url "https://kore.io/release/kore-1.2.3-release.tgz"
  sha256 "24f1a88f4ef3199d6585f821e1ef134bb448a1c9409a76d18fcccd4af940d32f"

  head "https://github.com/jorisvink/kore.git"


  depends_on "openssl"
  depends_on "postgresql" => :optional

  def install
    args = []

    args << "PGSQL=1" if build.with? "postgresql"

    system "make", "PREFIX=#{prefix}", "TASKS=1", *args
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/kore", "create", "test"
    system "#{bin}/kore", "build", "test"
    system "#{bin}/kore", "clean", "test"
  end
end
