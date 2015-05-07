class X264 < Formula
  homepage "https://www.videolan.org/developers/x264.html"
  # the latest commit on the stable branch
  url "https://git.videolan.org/git/x264.git", :revision => "c8a773ebfca148ef04f5a60d42cbd7336af0baf6"
  version "r2533"

  devel do
    # the latest commit on the master branch
    url "https://git.videolan.org/git/x264.git", :revision => "121396c71b4907ca82301d1a529795d98daab5f8"
    version "r2538"
  end

  head "https://git.videolan.org/git/x264.git"

  bottle do
    cellar :any
    sha1 "e8b121d25342b19c4723b4e05b8ad986dbb6295c" => :tiger_altivec
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
