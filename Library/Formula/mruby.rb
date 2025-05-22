class Mruby < Formula
  desc "Lightweight implementation of the Ruby language"
  homepage "http://www.mruby.org"
  url "https://github.com/mruby/mruby/archive/1.1.0.tar.gz"
  sha256 "134422735eeb73e47985343e1146f40ffe50760319c6c052c5517daedc9281ac"

  head "https://github.com/mruby/mruby.git"


  depends_on "bison" => :build

  def install
    system "make"

    cd "build/host/" do
      lib.install Dir["lib/*.a"]
      prefix.install %w[bin mrbgems mrblib tools]
    end

    prefix.install "include"
  end

  test do
    system "#{bin}/mruby", "-e", "true"
  end
end
