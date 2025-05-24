class Cfengine < Formula
  desc "Help manage and understand IT infrastructure"
  homepage "https://cfengine.com/"
  url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-3.7.0-2.tar.gz"
  version "3.7.0"
  sha256 "53e3fcae50b14d29a7a86920e13586cafed4eb5e2d081597dc9a7e34393c7f77"


  resource "masterfiles" do
    url "https://cfengine-package-repos.s3.amazonaws.com/tarballs/cfengine-masterfiles-3.7.0-2.tar.gz"
    version "3.7.0"
    sha256 "b9bc621484abb7fb06789ce79615e42501af50fdb2af4dadb115edc1b0b0980c"
  end

  depends_on "pcre"
  depends_on "lmdb"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "libxml2" if MacOS.version < :mountain_lion
  depends_on "openssl"

  def install
    system "autoreconf", "-Wno-portability", "-fvi", "-I", "m4" # see autogen.sh
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-workdir=#{var}/cfengine",
                          "--with-lmdb=#{Formula["lmdb"].opt_prefix}",
                          "--with-pcre=#{Formula["pcre"].opt_prefix}",
                          "--without-mysql",
                          "--without-postgresql"
    system "make", "install"
    (share/"cfengine/CoreBase").install resource("masterfiles")
  end

  test do
    system bin/"cf-key", "--show-hosts"
    assert_equal "CFEngine Core #{version}", shell_output("#{bin}/cf-agent -V").chomp
  end
end
