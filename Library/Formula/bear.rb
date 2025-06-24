class Bear < Formula
  desc "Generate compilation database for clang tooling"
  homepage "https://github.com/rizsotto/Bear"
  url "https://github.com/rizsotto/Bear/archive/2.0.4.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/b/bear/bear_2.0.4.orig.tar.gz"
  sha256 "33ea117b09068aa2cd59c0f0f7535ad82c5ee473133779f1cc20f6f99793a63e"
  head "https://github.com/rizsotto/Bear.git"


  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/bear", "true"
    assert File.exist? "compile_commands.json"
  end
end
