class Unoconv < Formula
  desc "Convert between any document format supported by OpenOffice"
  homepage "http://dag.wiee.rs/home-made/unoconv/"
  url "http://dag.wieers.com/home-made/unoconv/unoconv-0.7.tar.gz"
  sha256 "56abbec55632b19dcaff7d506ad6e2fd86f53afff412e622cc1e162afb1263fa"
  head "https://github.com/dagwieers/unoconv.git"


  depends_on :python if MacOS.version <= :snow_leopard

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  def caveats; <<-EOS.undent
    In order to use unoconv, a copy of LibreOffice between versions 3.6.0.1 - 4.3.x must be installed.
    EOS
  end
end
