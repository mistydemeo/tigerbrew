class OpenMesh < Formula
  desc "Generic data structure to represent and manipulate polygonal meshes"
  homepage "http://openmesh.org"
  url "http://www.openmesh.org/media/Releases/4.1/OpenMesh-4.1.tar.gz"
  sha256 "32e8d2218ebcb1c8ad9bd8645dcead26b76ee7d0980fc7a866683ac9860e5f20"


  head "http://openmesh.org/svnrepo/OpenMesh/trunk/", :using => :svn

  depends_on "cmake" => :build
  depends_on "qt" => :optional

  def install
    mkdir "build" do
      args = std_cmake_args

      if build.with? "qt"
        args << "-DBUILD_APPS=ON"
      else
        args << "-DBUILD_APPS=OFF"
      end

      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
    #include <iostream>
    #include <OpenMesh/Core/IO/MeshIO.hh>
    #include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>
    typedef OpenMesh::PolyMesh_ArrayKernelT<>  MyMesh;
    int main()
    {
        MyMesh mesh;
        MyMesh::VertexHandle vhandle[4];
        vhandle[0] = mesh.add_vertex(MyMesh::Point(-1, -1,  1));
        vhandle[1] = mesh.add_vertex(MyMesh::Point( 1, -1,  1));
        vhandle[2] = mesh.add_vertex(MyMesh::Point( 1,  1,  1));
        vhandle[3] = mesh.add_vertex(MyMesh::Point(-1,  1,  1));
        std::vector<MyMesh::VertexHandle>  face_vhandles;
        face_vhandles.clear();
        face_vhandles.push_back(vhandle[0]);
        face_vhandles.push_back(vhandle[1]);
        face_vhandles.push_back(vhandle[2]);
        face_vhandles.push_back(vhandle[3]);
        mesh.add_face(face_vhandles);
        try
        {
        if ( !OpenMesh::IO::write_mesh(mesh, "triangle.off") )
        {
            std::cerr << "Cannot write mesh to file 'triangle.off'" << std::endl;
            return 1;
        }
        }
        catch( std::exception& x )
        {
        std::cerr << x.what() << std::endl;
        return 1;
        }
        return 0;
    }

    EOS
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[ -I#{include} -L#{lib} -lOpenMeshCore -lOpenMeshTools]
    system ENV.cxx, "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
