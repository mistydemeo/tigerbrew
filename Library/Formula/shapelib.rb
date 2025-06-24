class Shapelib < Formula
  desc "Library for reading and writing ArcView Shapefiles"
  homepage "http://shapelib.maptools.org/"
  url "http://download.osgeo.org/shapelib/shapelib-1.3.0.tar.gz"
  sha256 "23d474016158ab5077db2f599527631706ba5c0dc7c4178a6a1d685bb014f68f"


  def install
    dylib = lib+"libshp.#{version}.dylib"

    system "make", "CC=#{ENV.cc}",
                   "CFLAGS=#{ENV.cflags}",
                   "PREFIX=#{prefix}"

    lib.mkpath
    system ENV.cc, *%W[-dynamiclib -Wl,-all_load
                       -Wl,-install_name,#{dylib}
                       -Wl,-headerpad_max_install_names
                       -Wl,-compatibility_version,#{version}
                       -o #{dylib}
                       shpopen.o shptree.o dbfopen.o safileio.o]

    include.install "shapefil.h"
    bin.install %w[shpcreate shpadd shpdump shprewind dbfcreate dbfadd dbfdump shptreedump]

    lib.install_symlink dylib.basename => "libshp.#{version.to_s.split(".").first}.dylib"
    lib.install_symlink dylib.basename => "libshp.dylib"
  end
end
