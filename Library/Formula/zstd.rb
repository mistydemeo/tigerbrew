class Zstd < Formula
  desc "Zstandard is a real-time compression algorithm"
  homepage "https://facebook.github.io/zstd/"
  url "https://github.com/facebook/zstd/archive/refs/tags/v1.5.6.tar.gz"
  mirror "http://fresh-center.net/linux/misc/zstd-1.5.6.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/zstd-1.5.6.tar.gz"
  sha256 "30f35f71c1203369dc979ecde0400ffea93c27391bfd2ac5a9715d2173d92ff7"
  license all_of: [
    { any_of: ["BSD-3-Clause", "GPL-2.0-only"] },
    "BSD-2-Clause", # programs/zstdgrep, lib/libzstd.pc.in
    "MIT", # lib/dictBuilder/divsufsort.c
  ]
  head "https://github.com/facebook/zstd.git", branch: "dev"

  bottle do
  end

  depends_on "cmake" => :build
  depends_on "lz4"
  depends_on "xz"
  depends_on "zlib"

  def install
    mkdir "builddir" do
      # Legacy support is the default after
      # https://github.com/facebook/zstd/commit/db104f6e839cbef94df4df8268b5fecb58471274
      # Set it to `ON` to be explicit about the configuration.
      system "cmake", "../build/cmake",
                      "-DZSTD_PROGRAMS_LINK_SHARED=ON", # link `zstd` to `libzstd`
                      "-DZSTD_BUILD_CONTRIB=ON",
                      "-DZSTD_LEGACY_SUPPORT=ON",
                      "-DZSTD_ZLIB_SUPPORT=ON",
                      "-DZSTD_LZMA_SUPPORT=ON",
                      "-DZSTD_LZ4_SUPPORT=ON",
                      "-DCMAKE_CXX_STANDARD=11",
                      *std_cmake_args
      system "make", "install"
    end

    # Prevent dependents from relying on fragile Cellar paths.
    # https://github.com/ocaml/ocaml/issues/12431
    inreplace lib/"pkgconfig/libzstd.pc", prefix, opt_prefix
  end

  test do
    [bin/"zstd", bin/"pzstd", "xz", "lz4", "gzip"].each do |prog|
      data = "Hello, #{prog}"
      assert_equal data, pipe_output("#{bin}/zstd -d", pipe_output(prog, data))
      if prog.to_s.end_with?("zstd")
        # `pzstd` can only decompress zstd-compressed data.
        assert_equal data, pipe_output("#{bin}/pzstd -d", pipe_output(prog, data))
      else
        assert_equal data, pipe_output("#{prog} -d", pipe_output("#{bin}/zstd --format=#{prog}", data))
      end
    end
  end
end
