class MediaInfo < Formula
  desc "Unified display of technical and tag data for audio/video"
  homepage "https://mediaarea.net/"
  url "https://mediaarea.net/download/binary/mediainfo/0.7.77/MediaInfo_CLI_0.7.77_GNU_FromSource.tar.bz2"
  version "0.7.77"
  sha256 "b96cbb358f6ae7d18f2a409a8945244fa053530736d00a8fb6d2cc0e7218a1f3"


  depends_on "pkg-config" => :build
  # fails to build against Leopard's older libcurl
  depends_on "curl" if MacOS.version < :snow_leopard

  if MacOS.version < :snow_leopard
    fails_with :gcc do
      cause "Fails with the libstdc++ in Leopard and older"
    end

    fails_with :gcc_4_0 do
      cause "Fails with the libstdc++ in Leopard and older"
    end

    fails_with :llvm do
      cause "Fails with the libstdc++ in Leopard and older"
    end
  end

  def install
    cd "ZenLib/Project/GNU/Library" do
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make"
    end

    cd "MediaInfoLib/Project/GNU/Library" do
      args = ["--disable-debug",
              "--disable-dependency-tracking",
              "--with-libcurl",
              "--prefix=#{prefix}"]
      system "./configure", *args
      system "make", "install"
    end

    cd "MediaInfo/Project/GNU/CLI" do
      system "./configure", "--disable-debug", "--disable-dependency-tracking",
                            "--prefix=#{prefix}"
      system "make", "install"
    end
  end

  test do
    pipe_output("#{bin}/mediainfo", test_fixtures("test.mp3"))
  end
end
