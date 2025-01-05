class Jsoncpp < Formula
  desc "Library for interacting with JSON"
  homepage "https://github.com/open-source-parsers/jsoncpp"
  url "https://github.com/open-source-parsers/jsoncpp/archive/0.10.7.tar.gz"
  sha256 "73e235c230708a8ac78ec11b886434a018f89691bd9e7fcf9c3128c8e677b435"

  bottle do
    cellar :any
    sha256 "e6ad7313bdab431b45400910f4a7747de9123f176bf9594aacb4396c94ef4677" => :tiger_altivec
  end

  depends_on "scons" => :build

  def install
    gccversion = `g++ -dumpversion`.strip
    libs = buildpath/"libs/linux-gcc-#{gccversion}/"

    scons "platform=linux-gcc"
    system "install_name_tool", "-id", lib/"libjsoncpp.dylib", libs/"libjson_linux-gcc-#{gccversion}_libmt.dylib"

    lib.install libs/"libjson_linux-gcc-#{gccversion}_libmt.dylib" => "libjsoncpp.dylib"
    lib.install libs/"libjson_linux-gcc-#{gccversion}_libmt.a" =>"libjsoncpp.a"
    (include/"jsoncpp").install buildpath/"include/json"

    (lib/"pkgconfig/jsoncpp.pc").write <<-EOS.undent
      prefix=#{prefix}
      exec_prefix=${prefix}
      libdir=#{lib}
      includedir=#{include}

      Name: jsoncpp
      Description: API for manipulating JSON
      Version: #{version}
      URL: https://github.com/open-source-parsers/jsoncpp
      Libs: -L${libdir} -ljsoncpp
      Cflags: -I${includedir}/jsoncpp/
    EOS
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <json/json.h>
      int main() {
        Json::Value root;
        Json::Reader reader;
        return reader.parse("[1, 2, 3]", root) ? 0: 1;
      }
    EOS
    system ENV.cxx, "test.cpp", "-o", "test",
                  "-I#{include}/jsoncpp",
                  "-L#{lib}",
                  "-ljsoncpp"
    system "./test"
  end
end
