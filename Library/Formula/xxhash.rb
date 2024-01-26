class Xxhash < Formula
  desc "Extremely fast non-cryptographic hash algorithm"
  homepage "https://github.com/Cyan4973/xxHash"
  url "https://github.com/Cyan4973/xxHash/archive/v0.8.2.tar.gz"
  sha256 "baee0c6afd4f03165de7a4e67988d16f0f2b257b51d0e3cb91909302a26a79c4"
  license all_of: [
    "BSD-2-Clause", # library
    "GPL-2.0-or-later", # `xxhsum` command line utility
  ]

  bottle do
    sha256 "71d9bf28acbfacdea460858a15298f3571dd0a2692cc7b4ec1911a89a1ea2bb1" => :tiger_altivec
  end

  def install
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    system "make"
    system "make", "install", "PREFIX=#{prefix}"
    prefix.install "cli/COPYING"
  end

  test do
    (testpath/"leaflet.txt").write "No computer should be without one!"
    assert_match(/^67bc7cc242ebc50a/, shell_output("#{bin}/xxhsum leaflet.txt"))
  end

  # -compatibility_version only allowed with -dynamiclib
  # -dylib_compatibility_version must be greater than zero
  patch :p0, :DATA
end
__END__
--- Makefile.orig	2023-05-20 22:53:44.000000000 +0100
+++ Makefile	2023-05-20 23:01:31.000000000 +0100
@@ -61,7 +61,7 @@
 	SHARED_EXT = dylib
 	SHARED_EXT_MAJOR = $(LIBVER_MAJOR).$(SHARED_EXT)
 	SHARED_EXT_VER = $(LIBVER).$(SHARED_EXT)
-	SONAME_FLAGS = -install_name $(LIBDIR)/libxxhash.$(SHARED_EXT_MAJOR) -compatibility_version $(LIBVER_MAJOR) -current_version $(LIBVER)
+	SONAME_FLAGS = -install_name $(LIBDIR)/libxxhash.$(SHARED_EXT_MAJOR) -compatibility_version $(LIBVER) -current_version $(LIBVER) -dynamiclib
 else
 	SONAME_FLAGS = -Wl,-soname=libxxhash.$(SHARED_EXT).$(LIBVER_MAJOR)
 	SHARED_EXT = so
