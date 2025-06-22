class Libxml2 < Formula
  desc "GNOME XML library"
  homepage "https://gitlab.gnome.org/GNOME/libxml2/-/wikis/home"
  url "https://download.gnome.org/sources/libxml2/2.11/libxml2-2.11.8.tar.xz"
  sha256 "53961af1721b72246180cd844b7ddae36ea8e1e4e27b683567990a1ee78b02c1"

  head do
    url "https://git.gnome.org/browse/libxml2", :using => :git

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "69550a566cdc2e31f81550b33d3470ff9d2c998dc34ac35ab807b555d91c44e8" => :tiger_altivec
  end

  depends_on "python" => :optional
  depends_on "xz"
  depends_on "zlib"

  keg_only :provided_by_osx

  option :universal

  def install
    ENV.universal_binary if build.universal?
    if build.head?
      inreplace "autogen.sh", "libtoolize", "glibtoolize"
      system "./autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-python",
                          "--with-lzma=#{Formula["xz"].opt_prefix}",
                          "--with-zlib=#{Formula["zlib"].opt_prefix}"
    system "make"
    ENV.deparallelize
    system "make", "install"

    if build.with? "python"
      cd "python" do
        # We need to insert our include dir first
        inreplace "setup.py", "includes_dir = [", "includes_dir = ['#{include}', '#{MacOS.sdk_path}/usr/include',"
        system "python", "setup.py", "install", "--prefix=#{prefix}"
      end
    end
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <libxml/tree.h>

      int main()
      {
        xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
        xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "root");
        xmlDocSetRootElement(doc, root_node);
        xmlFreeDoc(doc);
        return 0;
      }
    EOS
    args = `#{bin}/xml2-config --cflags --libs`.split
    args += %w[test.c -o test]
    system ENV.cc, *args
    system "./test"
  end
end
