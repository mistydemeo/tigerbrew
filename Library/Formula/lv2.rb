class Lv2 < Formula
  desc "Portable plugin standard for audio systems"
  homepage "http://lv2plug.in"
  url "http://lv2plug.in/spec/lv2-1.12.0.tar.bz2"
  sha256 "7a4a53138f10ed997174c8bc5a8573d5f5a5d8441aaac2de6cf2178ff90658e9"


  def install
    system "./waf", "configure", "--prefix=#{prefix}", "--lv2dir=#{share}/lv2", "--no-plugins"
    system "./waf", "build"
    system "./waf", "install"
  end
end
