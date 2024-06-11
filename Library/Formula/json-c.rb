class JsonC < Formula
  desc "JSON parser for C"
  homepage "https://github.com/json-c/json-c/wiki"
  url "https://s3.amazonaws.com/json-c_releases/releases/json-c-0.17.tar.gz"
  version "0.17"
  sha256 "7550914d58fb63b2c3546f3ccfbe11f1c094147bd31a69dcd23714d7956159e6"
  license "MIT"

  bottle do
  end

  # We build without -Werror, allow build on GCC 4.0.1.
  patch :p0, :DATA

  head do
    url "https://github.com/json-c/json-c.git"
  end

  option :universal

  depends_on "cmake" => :build

  def install
    ENV.universal_binary if build.universal?
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    mkdir "build" do
      system "cmake", "..", *std_cmake_args, "-DDISABLE_WERROR:BOOL=ON"
      system "make"
      system "make", "test", "install"
    end
  end
end
__END__
--- CMakeLists.txt.orig	2024-06-11 22:19:46.000000000 +0100
+++ CMakeLists.txt	2024-06-11 22:20:19.000000000 +0100
@@ -302,7 +302,6 @@
 	endif()
     set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} -Wall")
     set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} -Wcast-qual")
-    set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} -Wno-error=deprecated-declarations")
     set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} -Wextra")
     set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} -Wwrite-strings")
     set(CMAKE_C_FLAGS           "${CMAKE_C_FLAGS} -Wno-unused-parameter")
