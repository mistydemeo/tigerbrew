class Ptex < Formula
  desc "Texture mapping system"
  homepage "https://ptex.us"
  url "https://github.com/wdas/ptex/archive/v2.0.42.tar.gz"
  sha256 "4abdee8b51fa239d576d6b5a70f10d9ea56f51fa50408fe6b9440e11fe646658"

  # fix utils/Makefile not to expect a git repo for version info
  patch :DATA

  def install
    ENV.deparallelize # not parallel safe due to weird dep without rules for ../ptex/libPtex.a in utils/Makefile
    system "make -C src"
    prefix.install Dir["install/*"]
  end
end

__END__
diff --git a/src/utils/Makefile b/src/utils/Makefile
index 7638871..08a491a 100644
--- a/src/utils/Makefile
+++ b/src/utils/Makefile
@@ -38,8 +38,8 @@ all: install $(ALL)
 clean:
        rm -f $(ALL) $(INSTALLPATHS)

-PTEX_SHA = $(shell git rev-list --max-count=1 HEAD)
-PTEX_VER = $(shell git describe $(PTEX_SHA)) ($(PTEX_SHA))
+PTEX_SHA = 2f04c865fc921c4f90c581f1b6c04c566865c98a
+PTEX_VER = v2.0.32 ($(PTEX_SHA))

 ptxinfo: ptxinfo.cpp $(PTEX)
        $(CXX) $(CXXFLAGS) -DPTEX_VER='"$(PTEX_VER)"' $^ -o $@ $(LIBS)
