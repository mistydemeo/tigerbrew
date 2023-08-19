class TclTk < Formula
  desc "Tool Command Language"
  homepage "https://www.tcl.tk/"
  url "http://prdownloads.sourceforge.net/tcl/tcl8.6.13-src.tar.gz"
  version "8.6.13"
  sha256 "43a1fae7412f61ff11de2cfd05d28cfc3a73762f354a417c62370a54e2caf066"

  bottle do
    sha256 "6c1a82cf1a22895eaccac3cd42dd7efcf5b6eb9d79e10826ea656bf063db4629" => :tiger_altivec
  end

  keg_only :provided_by_osx,
    "Tk installs some X11 headers and OS X provides an (older) Tcl/Tk."

  deprecated_option "enable-threads" => "with-threads"

  option "with-threads", "Build with multithreading support"
  option "without-tcllib", "Don't build tcllib (utility modules)"
  option "without-tk", "Don't build the Tk (window toolkit)"

  depends_on :x11 if MacOS.version < :snow_leopard
  depends_on "pkg-config" => :build if build.with? "x11"
  depends_on "sqlite"
  depends_on "zlib"

  resource "tk" do
    url "http://prdownloads.sourceforge.net/tcl/tk8.6.13-src.tar.gz"
    version "8.6.13"
    sha256 "2e65fa069a23365440a3c56c556b8673b5e32a283800d8d9b257e3f584ce0675"
  end

  resource "tcllib" do
    url "https://downloads.sourceforge.net/project/tcllib/tcllib/1.21/tcllib-1.21.tar.xz"
    sha256 "10c7749e30fdd6092251930e8a1aa289b193a3b7f1abf17fee1d4fa89814762f"
  end

  def install
    # Build breaks passing -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    args = ["--prefix=#{prefix}", "--mandir=#{man}", "--with-system-sqlite"]
    args << "--enable-threads" if build.with? "threads"
    args << "--enable-64bit" if MacOS.prefer_64_bit?

    cd "unix" do
      system "./configure", *args
      system "make"
      system "make", "install"
      system "make", "install-private-headers"
      ln_s bin/"tclsh8.6", bin/"tclsh"
    end

    if build.with? "tk"
      ENV.prepend_path "PATH", bin # so that tk finds our new tclsh

      resource("tk").stage do
        args = ["--prefix=#{prefix}", "--mandir=#{man}", "--with-tcl=#{lib}"]
        args << "--enable-threads" if build.with? "threads"
        args << "--enable-64bit" if MacOS.prefer_64_bit?

        # Aqua support now requires features introduced in Snow Leopard at least
        if MacOS.version < :snow_leopard
          args << "--with-x"
        else
          args << "--enable-aqua=yes"
          args << "--without-x"
        end

        cd "unix" do
          system "./configure", *args
          system "make", "TK_LIBRARY=#{lib}"
          # system "make", "test"  # for maintainers
          system "make", "install"
          system "make", "install-private-headers"
          ln_s bin/"wish8.6", bin/"wish"
        end
      end
    end

    if build.with? "tcllib"
      resource("tcllib").stage do
        system "./configure", "--prefix=#{prefix}",
                              "--mandir=#{man}"
        system "make", "install"
      end
    end
  end

  test do
    assert_equal "honk", pipe_output("#{bin}/tclsh", "puts honk\n").chomp
  end
end
