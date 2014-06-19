require 'formula'

class FluidSynth < Formula
  homepage 'http://www.fluidsynth.org'
  url 'https://downloads.sourceforge.net/project/fluidsynth/fluidsynth-1.1.6/fluidsynth-1.1.6.tar.gz'
  sha1 '155de731e72e91e1d4b7f52c33d8171596fbf244'

  depends_on 'pkg-config' => :build
  depends_on 'cmake' => :build
  depends_on 'glib'
  depends_on 'libsndfile' => :optional
  
  patch :DATA if MacOS.version == :tiger

  def install
    mkdir 'build' do
      if MacOS.version == :tiger
        system "cmake", "..", "-Denable-framework=OFF", "-DLIB_SUFFIX=", "-DCMAKE_C_COMPILER=gcc-4.0", "-DCMAKE_CXX_COMPILER=g++-4.0", "-DCMAKE_C_FLAGS=-fno-common", *std_cmake_args
      else
        system "cmake", "..", "-Denable-framework=OFF", "-DLIB_SUFFIX=", *std_cmake_args
      end
      system "make install"
    end
  end
end
__END__
diff --git a/src/drivers/fluid_coreaudio.c b/src/drivers/fluid_coreaudio.c
index d7c22e3..ebb9c88 100644
--- a/src/drivers/fluid_coreaudio.c
+++ b/src/drivers/fluid_coreaudio.c
@@ -33,6 +33,23 @@
 #include "config.h"
 
 #if COREAUDIO_SUPPORT
+
+/* Work around for OSX 10.4 */
+
+/* enum definition in OpenTransportProviders.h defines these tokens
+   which are #defined from <netinet/tcp.h> */
+#ifdef TCP_NODELAY
+#undef TCP_NODELAY
+#endif
+#ifdef TCP_MAXSEG
+#undef TCP_MAXSEG
+#endif
+#ifdef TCP_KEEPALIVE
+#undef TCP_KEEPALIVE
+#endif
+
+/* End work around */
+
 #include <CoreServices/CoreServices.h>
 #include <CoreAudio/CoreAudioTypes.h>
 #include <CoreAudio/AudioHardware.h>
-- 
2.0.0

