class Aspcud < Formula
  desc "Package dependency solver"
  homepage "http://potassco.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/potassco/aspcud/1.9.1/aspcud-1.9.1-source.tar.gz"
  sha256 "e0e917a9a6c5ff080a411ff25d1174e0d4118bb6759c3fe976e2e3cca15e5827"


  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "re2c"  => :build
  depends_on "gringo"
  depends_on "clasp"

  def install
    args = std_cmake_args
    args << "-DGRINGO_LOC=#{Formula["gringo"].opt_bin}/gringo"
    args << "-DCLASP_LOC=#{Formula["clasp"].opt_bin}/clasp"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    fixture = <<-EOS.undent
      package: foo
      version: 1

      request: foo >= 1
    EOS

    (testpath/"in.cudf").write(fixture)
    system "#{bin}/aspcud", "in.cudf", "out.cudf"
  end
end
