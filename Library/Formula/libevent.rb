class Libevent < Formula
  desc "Asynchronous event library"
  homepage "http://libevent.org"
  url "https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz"
  sha256 "92e6de1be9ec176428fd2367677e61ceffc2ee1cb119035037a27d346b0403bb"

  bottle do
    cellar :any
    sha256 "968c69226279617bd8abc9641c602706e184ad8fab99275675070cf65a99d3eb" => :el_capitan
    sha1 "d70fff6a306440f4104ff934eec1fd35683724a4" => :yosemite
    sha1 "7d86d36fff109699bcec092f708d1be61c86ef78" => :mavericks
    sha1 "e074607f84ab34a1e939f6a93bf3fc2b6c90d9bd" => :mountain_lion
  end

  head do
    url "https://github.com/libevent/libevent.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "doxygen" => [:optional, :build]
  depends_on "pkg-config" => :build
  depends_on "openssl"

  option :universal
  option "with-doxygen", "Build and install the manpages (using Doxygen)"

  deprecated_option "enable-manpages" => "with-doxygen"

  fails_with :llvm do
    build 2326
    cause "Undefined symbol '_current_base' reported during linking."
  end

  def install
    ENV.universal_binary if build.universal?
    ENV.j1

    if build.with? "doxygen"
      inreplace "Doxyfile", /GENERATE_MAN\s*=\s*NO/, "GENERATE_MAN = YES"
    end

    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-debug-mode",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"

    if build.with? "doxygen"
      system "make", "doxygen"
      man3.install Dir["doxygen/man/man3/*.3"]
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <event2/event.h>

      int main()
      {
        struct event_base *base;
        base = event_base_new();
        event_base_free(base);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-levent", "-o", "test"
    system "./test"
  end
end
