class Snort < Formula
  desc "Flexible Network Intrusion Detection System"
  homepage "https://www.snort.org"
  url "https://www.snort.org/downloads/snort/snort-2.9.7.3.tar.gz"
  sha256 "8cc3613b888fc54947a2beec773c76d9a20368f2659b31d45a9f0b11e66cc229"


  depends_on "pkg-config" => :build
  depends_on "luajit"
  depends_on "daq"
  depends_on "libdnet"
  depends_on "pcre"
  depends_on "openssl"

  option "with-debug", "Compile Snort with debug options enabled"

  deprecated_option "enable-debug" => "with-debug"

  def install
    openssl = Formula["openssl"]

    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}/snort
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-gre
      --enable-mpls
      --enable-targetbased
      --enable-sourcefire
      --with-openssl-includes=#{openssl.opt_include}
      --with-openssl-libraries=#{openssl.opt_lib}
      --enable-active-response
      --enable-normalizer
      --enable-reload
      --enable-react
      --enable-flexresp3
    ]

    if build.with? "debug"
      args << "--enable-debug"
      args << "--enable-debug-msgs"
    else
      args << "--disable-debug"
    end

    system "./configure", *args
    system "make", "install"

    rm Dir[buildpath/"etc/Makefile*"]
    (etc+"snort").install Dir[buildpath/"etc/*"]
  end

  def caveats; <<-EOS.undent
    For snort to be functional, you need to update the permissions for /dev/bpf*
    so that they can be read by non-root users.  This can be done manually using:
        sudo chmod 644 /dev/bpf*
    or you could create a startup item to do this for you.
    EOS
  end

  test do
    system bin/"snort", "-V"
  end
end
