class Curaengine < Formula
  desc "C++ 3D printing GCode generator"
  homepage "https://github.com/Ultimaker/CuraEngine"
  url "https://github.com/Ultimaker/CuraEngine/archive/15.04.tar.gz"
  sha256 "d577e409b3e9554e7d2b886227dbbac6c9525efe34df4fc7d62e9474a2d7f965"

  head "https://github.com/Ultimaker/CuraEngine.git"


  def install
    system "make", "VERSION=#{version}"
    bin.install "build/CuraEngine"
  end

  test do
    (testpath/"t.stl").write <<-EOF.undent
      solid t
        facet normal 0 -1 0
         outer loop
          vertex 0.83404 0 0.694596
          vertex 0.36904 0 1.5
          vertex 1.78814e-006 0 0.75
         endloop
        endfacet
      endsolid Star
    EOF

    system "#{bin}/CuraEngine", "#{testpath}/t.stl"
  end
end
