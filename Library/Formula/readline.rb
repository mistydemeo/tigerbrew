require "formula"

class Readline < Formula
  homepage "http://tiswww.case.edu/php/chet/readline/rltop.html"
  url "http://ftpmirror.gnu.org/readline/readline-6.3.tar.gz"
  mirror "http://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz"
  sha256 "56ba6071b9462f980c5a72ab0023893b65ba6debb4eeb475d7a563dc65cafd43"
  version "6.3.8"

  bottle do
    cellar :any
    sha1 "94069a1b339cde692ab0bd7ee334eb34647ece25" => :tiger_g3
    sha1 "892efe7f1102c00fd495bb54fc940f5279926b3c" => :tiger_altivec
    sha1 "ebbdff05fac504353985c6ba342b95c9e205e0c5" => :leopard_g3
    sha1 "40c520d89df0c29bfbc4bd5f147b65392cf28d1b" => :leopard_altivec
  end

  keg_only :shadowed_by_osx, <<-EOS
OS X provides the BSD libedit library, which shadows libreadline.
In order to prevent conflicts when programs look for libreadline we are
defaulting this GNU Readline installation to keg-only.
EOS

  # Vendor the patches.
  # The mirrors are unreliable for getting the patches, and the more patches
  # there are, the more unreliable they get. Pulling this patch inline to
  # reduce bug reports.
  # Upstream patches can be found in:
  # http://git.savannah.gnu.org/cgit/readline.git
  patch do
    url "https://gist.githubusercontent.com/jacknagel/d886531fb6623b60b2af/raw/746fc543e56bc37a26ccf05d2946a45176b0894e/readline-6.3.8.diff"
    sha1 "dccc973e4a75ecfe45c25c296e0f7785b06586dc"
  end

  def install
    ENV.universal_binary
    system "./configure", "--prefix=#{prefix}", "--enable-multibyte"
    system "make install"

    # The 6.3 release notes say:
    #   When creating shared libraries on Mac OS X, the pathname written into the
    #   library (install_name) no longer includes the minor version number.
    # Software will link against libreadline.6.dylib instead of libreadline.6.3.dylib.
    # Therefore we create symlinks to avoid bumping the revisions on dependents.
    # This should be removed at 6.4.
    lib.install_symlink "libhistory.6.3.dylib" => "libhistory.6.2.dylib",
                        "libreadline.6.3.dylib" => "libreadline.6.2.dylib"
  end
end
