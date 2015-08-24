class X264 < Formula
  desc "H.264/AVC encoder"
  homepage "https://www.videolan.org/developers/x264.html"
  # the latest commit on the stable branch
  url "https://git.videolan.org/git/x264.git", :revision => "0c21480fa2fdee345a3049e2169624dc6fc2acfc"
  version "r2555"

  devel do
    # the latest commit on the master branch
    url "https://git.videolan.org/git/x264.git", :revision => "73ae2d11d472d0eb3b7c218dc1659db32f649b14"
    version "r2579"
  end

  head "https://git.videolan.org/git/x264.git"

  bottle do
    cellar :any
    sha256 "13edbf4f3344fcb9791a885b0eaadc32790908beade8313911684d7d441da3ab" => :tiger_altivec
    sha256 "564f2062ebcf2bc440a5c1b58fd2128ddadedb266b773676ea3c9b33e5b44502" => :leopard_g3
    sha256 "649a0123fcd0f30c55d5b3f893e5f790854a8337e1560560809e55055eb14653" => :leopard_altivec
  end

  depends_on :ld64
  # reports that ASM causes a crash on G3; works on G4
  depends_on "yasm" => :build unless Hardware::CPU.family == :g3

  option "with-10-bit", "Build a 10-bit x264 (default: 8-bit)"
  option "with-mp4=", "Select mp4 output: none (default), l-smash or gpac"

  deprecated_option "10-bit" => "with-10-bit"

  case ARGV.value "with-mp4"
  when "l-smash" then depends_on "l-smash"
  when "gpac" then depends_on "gpac"
  end

  def install
    # On Darwin/PPC x264 always uses -fastf,
    # which isn't supported by FSF GCC.
    if ![:gcc, :llvm, :gcc_4_0].include? ENV.compiler
      inreplace "configure", "-fastf", ""
    end
    
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-static
      --enable-strip
    ]
    if Formula["l-smash"].installed?
      args << "--disable-gpac"
    elsif Formula["gpac"].installed?
      args << "--disable-lsmash"
    end

    args << "--bit-depth=10" if build.with? "10-bit"
    args << "--disable-asm" if Hardware::CPU.family == :g3

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdint.h>
      #include <x264.h>

      int main()
      {
          x264_picture_t pic;
          x264_picture_init(&pic);
          x264_picture_alloc(&pic, 1, 1, 1);
          x264_picture_clean(&pic);
          return 0;
      }
    EOS
    system ENV.cc, "-lx264", "test.c", "-o", "test"
    system "./test"
  end
end
