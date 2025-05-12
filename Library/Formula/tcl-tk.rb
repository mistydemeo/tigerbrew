class TclTk < Formula
  desc "Tool Command Language"
  homepage "https://www.tcl.tk/"
  url "http://prdownloads.sourceforge.net/tcl/tcl8.6.16-src.tar.gz"
  version "8.6.16"
  sha256 "91cb8fa61771c63c262efb553059b7c7ad6757afa5857af6265e4b0bdc2a14a5"

  bottle do
    sha256 "19009ca7d37ad310840cba54d856759657ac9fedb06bdd962eb9614a7bef13db" => :tiger_altivec
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
    url "http://prdownloads.sourceforge.net/tcl/tk8.6.16-src.tar.gz"
    version "8.6.16"
    sha256 "be9f94d3575d4b3099d84bc3c10de8994df2d7aa405208173c709cc404a7e5fe"
  end

  resource "tcllib" do
    url "https://downloads.sourceforge.net/project/tcllib/tcllib/2.0/tcllib-2.0.tar.xz"
    sha256 "642c2c679c9017ab6fded03324e4ce9b5f4292473b62520e82aacebb63c0ce20"
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
