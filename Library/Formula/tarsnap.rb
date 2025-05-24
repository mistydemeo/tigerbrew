class Tarsnap < Formula
  desc "Online backups for the truly paranoid"
  homepage "https://www.tarsnap.com/"
  url "https://www.tarsnap.com/download/tarsnap-autoconf-1.0.36.1.tgz"
  sha256 "a2909e01e2f983179d63ef2094c42102c92c716032864e66ef25ae341ea28690"


  head do
    url "https://github.com/Tarsnap/tarsnap.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "openssl"
  depends_on "xz" => :optional

  def install
    system "autoreconf", "-iv" if build.head?

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-bash-completion-dir=#{bash_completion}
    ]
    args << "--without-lzma" << "--without-lzmadec" if build.without? "xz"

    system "./configure", *args
    system "make", "install"
  end

  test do
    system bin/"tarsnap", "-c", "--dry-run", testpath
  end
end
