class Mandoc < Formula
  desc "The mandoc UNIX manpage compiler toolset"
  homepage "https://mdocml.bsd.lv"
  url "https://mandoc.bsd.lv/snapshots/mandoc-1.14.6.tar.gz"
  sha256 "8bf0d570f01e70a6e124884088870cbed7537f36328d512909eb10cd53179d9c"

  bottle do
    sha256 "2bb7ad646fc08ae741bde37613ccfa166beac3f106048061f2a79f2dd57de04a" => :tiger_altivec
  end

  head "anoncvs@mdocml.bsd.lv:/cvs", :module => "mdocml", :using => :cvs

  option "without-sqlite", "Only install the mandoc/demandoc utilities."
  option "without-cgi", "Don't build man.cgi (and extra CSS files)."

  depends_on "sqlite" => :recommended

  def install
    localconfig = [

      "PREFIX=#{prefix}",
      "INCLUDEDIR=#{include}",
      "LIBDIR=#{lib}",
      "MANDIR=#{man}",
      "WWWPREFIX=#{prefix}/var/www",
      "EXAMPLEDIR=#{share}/examples",

      # These are names for *section 7* pages only. Several other pages are
      # prefixed "mandoc_", similar to the "groff_" pages.
      "MANM_MAN=man",
      "MANM_MDOC=mdoc",
      "MANM_ROFF=mandoc_roff", # This is the only one that conflicts (groff).
      "MANM_EQN=eqn",
      "MANM_TBL=tbl",

      "OSNAME='Mac OS X #{MacOS.version}'", # Bottom corner signature line.

      # Add the Tigerbrew manual path alongside the default which would used if not specified.
      "MANPATH_DEFAULT=#{HOMEBREW_PREFIX}/share/man:/usr/share/man:/usr/X11R6/man:/usr/local/man",

      "STATIC=",          # No static linking on Darwin.

      "READ_ALLOWED_PATH=#{HOMEBREW_CELLAR}" # ? See configure.local.example, NEWS.
    ]

    localconfig << "BUILD_DB=1" if build.with? "db"
    localconfig << "BUILD_CGI=1" if build.with? "cgi"
    File.rename("cgi.h.example", "cgi.h") # For man.cgi, harmless in any case.

    (buildpath/"configure.local").write localconfig.join("\n")
    system "./configure"

    ENV.deparallelize do
      system "make"
      system "make", "install"
    end
  end

  test do
    system "mandoc", "-Thtml",
      "-Ostyle=#{share}/examples/example.style.css",
      "#{HOMEBREW_PREFIX}/share/man/man1/brew.1"
  end
end
