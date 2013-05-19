require 'formula'

class Xmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/xmp/xmp/4.0.5/xmp-4.0.5.tar.gz'
  sha1 '3de0292afc8c0e28b3f2f9328b28bc19d0fda9d1'
  head 'git://git.code.sf.net/p/xmp/xmp-cli'

  depends_on :autoconf if build.head?
  depends_on 'pkg-config' => :build
  depends_on 'libxmp'

  def install
    system "autoconf" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make install"

    # install the included demo song
    share.install "ub-name.it" unless build.head?
  end

  def test
    system "#{bin}/xmp", "--load-only", share/"ub-name.it"
  end
end

__END__
diff --git a/src/sound_coreaudio.c b/src/sound_coreaudio.c
index 2fb1893..06ca90b 100644
--- a/src/sound_coreaudio.c
+++ b/src/sound_coreaudio.c
@@ -133,8 +133,8 @@ static int init(struct options *options)
 
 	ad.mSampleRate = options->rate;
 	ad.mFormatID = kAudioFormatLinearPCM;
-	ad.mFormatFlags = kAudioFormatFlagIsPacked /* |
-			kAudioFormatFlagNativeEndian */;
+	ad.mFormatFlags = kAudioFormatFlagIsPacked |
+			kAudioFormatFlagsNativeEndian;
 
 	if (~options->format & XMP_FORMAT_UNSIGNED) {
 		ad.mFormatFlags |= kAudioFormatFlagIsSignedInteger;

