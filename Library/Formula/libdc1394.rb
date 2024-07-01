class Libdc1394 < Formula
  desc "Provides API for IEEE 1394 cameras"
  homepage "https://damien.douxchamps.net/ieee1394/libdc1394/"
  url "https://downloads.sourceforge.net/project/libdc1394/libdc1394-2/2.2.6/libdc1394-2.2.6.tar.gz"
  sha256 "2b905fc9aa4eec6bdcf6a2ae5f5ba021232739f5be047dec8fe8dd6049c10fed"

  bottle do
    cellar :any
    sha256 "3488c0e3611d576663d1b4e6ecda4bcd56fd5479be303ff6eb11bed54d3b1404" => :tiger_altivec
  end

  option :universal

  depends_on "sdl"
  depends_on "libusb"

  # fix issue due to bug in OSX Firewire stack
  # libdc1394 author comments here:
  # http://permalink.gmane.org/gmane.comp.multimedia.libdc1394.devel/517
  patch :DATA

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-examples",
                          "--disable-sdltest"
    system "make", "install"
  end
end

__END__
diff --git a/dc1394/macosx/capture.c b/dc1394/macosx/capture.c
index c7c71f2..8959535 100644
--- a/dc1394/macosx/capture.c
+++ b/dc1394/macosx/capture.c
@@ -150,7 +150,7 @@ callback (buffer_info * buffer, NuDCLRef dcl)
 
     for (i = 0; i < buffer->num_dcls; i++) {
         int packet_size = capture->frames[buffer->i].packet_size;
-        if ((buffer->pkts[i].status & 0x1F) != 0x11) {
+        if (buffer->pkts[i].status && (buffer->pkts[i].status & 0x1F) != 0x11) {
             dc1394_log_warning ("packet %d had error status %x",
                     i, buffer->pkts[i].status);
             corrupt = 1;
