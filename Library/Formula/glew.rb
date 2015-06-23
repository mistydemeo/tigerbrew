class Glew < Formula
  desc "OpenGL Extension Wrangler Library"
  homepage "http://glew.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/glew/glew/1.12.0/glew-1.12.0.tgz"
  sha256 "af58103f4824b443e7fa4ed3af593b8edac6f3a7be3b30911edbc7344f48e4bf"

  bottle do
    cellar :any
    sha256 "61f5c3d9a7e23c6349a98aeec0ca23fd3165e3cd74016cfcd307a02c5a602b1a" => :leopard_g3
    sha256 "4b6e4e782322ff5f9a386bf2ce533717616bd610ad487450fcfeb889c596e84f" => :leopard_altivec
  end

  option :universal

  def install
    # Makefile directory race condition on lion
    ENV.deparallelize

    if build.universal?
      ENV.universal_binary

      # Do not strip resulting binaries; https://sourceforge.net/p/glew/bugs/259/
      ENV["STRIP"] = ""
    end

    inreplace "glew.pc.in", "Requires: @requireslib@", ""
    system "make", "GLEW_PREFIX=#{prefix}", "GLEW_DEST=#{prefix}", "all"
    system "make", "GLEW_PREFIX=#{prefix}", "GLEW_DEST=#{prefix}", "install.all"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/glewinfo")
  end
end
