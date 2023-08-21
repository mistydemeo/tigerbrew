class Graphviz < Formula
  desc "Graph visualization software from AT&T and Bell Labs"
  homepage "http://graphviz.org/"
  url "https://gitlab.com/graphviz/graphviz/-/package_files/6163716/download"
  sha256 "e90b19ebf131afa2f75a043f13ce5a3555c787ea7c35e74b6c95840d34f056ec"
  version "2.46.0"

  head do
    url "https://gitlab.com/graphviz/graphviz"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
  end

  bottle do
    sha256 "b81798e21bf75f274613ff57060ac767d304fbb3dd18cfd03eb7a35c5a274ebc" => :tiger_altivec
  end

  # To find Ruby and Co.
  env :std

  option :universal
  option "with-bindings", "Build Perl/Python/Ruby/etc. bindings"
  option "with-pango", "Build with Pango/Cairo for alternate PDF output"
  option "with-app", "Build GraphViz.app (requires full XCode install)"
  option "with-gts", "Build with GNU GTS support (required by prism)"

  deprecated_option "with-x" => "with-x11"
  deprecated_option "with-pangocairo" => "with-pango"

  depends_on "pkg-config" => :build
  depends_on :xcode => :build if build.with? "app"
  depends_on "pango" => :optional
  depends_on "gts" => :optional
  depends_on "librsvg" => :optional
  depends_on "freetype" => :optional
  depends_on :x11 => :optional
  depends_on "libpng"

  if build.with? "bindings"
    depends_on "swig" => :build
    depends_on :python
    depends_on :java
  end

  def install
    ENV.universal_binary if build.universal?
    args = ["--disable-debug",
            "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--without-qt"]
    args << "--with-quartz" if MacOS.version >= :leopard
    args << "--with-gts" if build.with? "gts"
    args << "--disable-swig" if build.without? "bindings"
    args << "--without-pangocairo" if build.without? "pango"
    args << "--without-freetype2" if build.without? "freetype"
    args << "--without-x" if build.without? "x11"
    args << "--without-rsvg" if build.without? "librsvg"

    if build.with? "bindings"
      # http://www.graphviz.org/mantisbt/view.php?id=2486
      inreplace "configure", 'PYTHON_LIBS="-lpython$PYTHON_VERSION_SHORT"',
                             'PYTHON_LIBS="-L$PYTHON_PREFIX/lib -lpython$PYTHON_VERSION_SHORT"'
    end

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make", "install"

    if build.with? "app"
      cd "macosx" do
        xcodebuild "-configuration", "Release", "SYMROOT=build", "PREFIX=#{prefix}", "ONLY_ACTIVE_ARCH=YES"
      end
      prefix.install "macosx/build/Release/Graphviz.app"
    end

    (bin+"gvmap.sh").unlink
  end

  test do
    (testpath/"sample.dot").write <<-EOS.undent
    digraph G {
      a -> b
    }
    EOS

    system "#{bin}/dot", "-Txdot", "-o", "sample.xdot", "sample.dot"
  end
end
