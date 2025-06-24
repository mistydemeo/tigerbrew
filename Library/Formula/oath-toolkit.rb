class OathToolkit < Formula
  desc "Tools for one-time password authentication systems"
  homepage "http://www.nongnu.org/oath-toolkit/"
  url "http://download.savannah.gnu.org/releases/oath-toolkit/oath-toolkit-2.6.1.tar.gz"
  mirror "https://fossies.org/linux/privat/oath-toolkit-2.6.1.tar.gz"
  sha256 "9c57831907bc26eadcdf90ba1827d0bd962dd1f737362e817a1dd6d6ec036f79"


  depends_on "pkg-config" => :build
  depends_on "libxmlsec1"

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end
end
