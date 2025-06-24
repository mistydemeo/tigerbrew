class Enca < Formula
  desc "Charset analyzer and converter"
  homepage "http://cihar.com/software/enca/"
  url "http://dl.cihar.com/enca/enca-1.16.tar.gz"
  sha256 "de63ce06b373964ee5fbb3fea8286876de03ee095b1a2e3b7d28a940a13aff6f"
  head "https://github.com/nijel/enca.git"


  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    enca = "#{bin}/enca --language=none"
    assert_match /ASCII/, `#{enca} <<< 'Testing...'`
    assert_match /UCS-2/, `#{enca} --convert-to=UTF-16 <<< 'Testing...' | #{enca}`
  end
end
