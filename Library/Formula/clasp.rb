class Clasp < Formula
  desc "Answer set solver for (extended) normal logic programs"
  homepage "http://potassco.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/potassco/clasp/3.1.3/clasp-3.1.3-source.tar.gz"
  sha256 "f08684eadfa5ae5efa5c06439edc361b775fc55b7c1a9ca862eda8f5bf7e5f1f"


  option "with-mt", "Enable multi-thread support"

  depends_on "tbb" if build.with? "mt"

  def install
    if build.with? "mt"
      ENV["TBB30_INSTALL_DIR"] = Formula["tbb"].opt_prefix
      build_dir = "build/release_mt"
    else
      build_dir = "build/release"
    end

    args = %W[
      --config=release
      --prefix=#{prefix}
    ]
    args << "--with-mt" if build.with? "mt"

    bin.mkpath
    system "./configure.sh", *args
    system "make", "-C", build_dir, "install"
  end

  test do
    assert_match /#{version}/, shell_output("#{bin}/clasp --version")
  end
end
