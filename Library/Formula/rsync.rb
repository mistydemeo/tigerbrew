class Rsync < Formula
  desc "Utility that provides fast incremental file transfer"
  homepage "https://rsync.samba.org/"
  url "https://download.samba.org/pub/rsync/rsync-3.4.1.tar.gz"
  mirror "https://www.mirrorservice.org/sites/rsync.samba.org/rsync-3.4.1.tar.gz"
  sha256 "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52"
  license "GPL-3.0-or-later"

  bottle do
  end

  depends_on "lz4"
  depends_on "openssl3"
  depends_on "popt"
  depends_on "xxhash"
  depends_on "zlib"

  # This patch provides --fileflags, which preserves the st_flags stat() field.
  patch do
    url "https://download.samba.org/pub/rsync/src/rsync-patches-3.4.1.tar.gz"
    mirror "https://www.mirrorservice.org/sites/rsync.samba.org/rsync-patches-3.4.1.tar.gz"
    sha256 "f56566e74cfa0f68337f7957d8681929f9ac4c55d3fb92aec0d743db590c9a88"
    apply "patches/fileflags.diff"
  end

  def install
    ENV.append_to_cflags "-DSUPPORT_FILEFLAGS"
    args = %W[
      --prefix=#{prefix}
      --with-rsyncd-conf=#{etc}/rsyncd.conf
      --with-included-popt=no
      --with-included-zlib=no
      --enable-ipv6
      --disable-zstd
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    mkdir "a"
    mkdir "b"

    ["foo\n", "bar\n", "baz\n"].map.with_index do |s, i|
      (testpath/"a/#{i + 1}.txt").write s
    end

    system bin/"rsync", "-artv", testpath/"a/", testpath/"b/"

    (1..3).each do |i|
      assert_equal (testpath/"a/#{i}.txt").read, (testpath/"b/#{i}.txt").read
    end
  end
end
