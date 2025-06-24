class Ponyc < Formula
  desc "Object-oriented, actor-model, capabilities-secure programming language"
  homepage "http://www.ponylang.org"
  url "http://releases.ponylang.org/source/ponyc-0.1.7.tar.bz2"
  sha256 "fc6f783f65cd6708a80bdea71f414cada801528143ea22d9bb13957cb7061eb6"
  head "https://github.com/CausalityLtd/ponyc.git"


  depends_on "llvm" => "with-rtti"
  needs :cxx11

  def install
    ENV.cxx11
    system "make", "install", "config=release", "destdir=#{prefix}"
  end

  test do
    system "#{bin}/ponyc", "-rexpr", "#{prefix}/packages/builtin"
  end
end
