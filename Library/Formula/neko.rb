class Neko < Formula
  desc "High-level, dynamically typed programming language"
  homepage "http://nekovm.org"
  # revision includes recent parameterized build targets for mac.  Use a :tag
  # on the next release
  url "https://github.com/HaxeFoundation/neko.git", :revision => "22c49a89b56b9f106d7162710102e9475227e882"
  version "2.0.0-22c49a8"
  revision 2

  head "https://github.com/HaxeFoundation/neko.git"


  depends_on "bdw-gc"
  depends_on "pcre"
  depends_on "openssl"

  def install
    # Build requires targets to be built in specific order
    ENV.deparallelize
    system "make", "os=osx", "LIB_PREFIX=#{HOMEBREW_PREFIX}", "INSTALL_FLAGS="

    include.install Dir["vm/neko*.h"]
    neko = lib/"neko"
    neko.install Dir["bin/*"]

    # Symlink into bin so libneko.dylib resolves correctly for custom prefix
    %w[neko nekoc nekoml nekotools].each do |file|
      bin.install_symlink neko/file
    end
    lib.install_symlink neko/"libneko.dylib"
  end

  test do
    ENV["NEKOPATH"] = "#{HOMEBREW_PREFIX}/lib/neko"
    system "#{bin}/neko", "#{HOMEBREW_PREFIX}/lib/neko/test.n"
  end

  def caveats
    s = ""
    if HOMEBREW_PREFIX.to_s != "/usr/local"
      s << <<-EOS.undent
        You must add the following line to your .bashrc or equivalent:
          export NEKOPATH="#{HOMEBREW_PREFIX}/lib/neko"
        EOS
    end
    s
  end
end
