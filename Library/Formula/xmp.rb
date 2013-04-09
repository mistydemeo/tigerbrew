require 'formula'

class Xmp < Formula
  homepage 'http://xmp.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/xmp/xmp/4.0.2/xmp-4.0.2.tar.gz'
  sha1 '32c2d5884cd94cfbc442095200d625b9f7ec6d2d'

  depends_on 'libxmp'

  # coreaudio driver assumes little-endian; fixed upstream,
  # will be in next release
  # http://sourceforge.net/mailarchive/forum.php?thread_name=CAGfWt5cHP8kdFXKS3K_NZEOg3WYGK0Zk2U6pVPmfnRHT7cx%3DDA%40mail.gmail.com&forum_name=xmp-devel
  def patches; DATA; end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make install"

    # install the included demo song
    share.install "08_sad_song.it"
  end

  def test
    system "#{bin}/xmp", "--load-only", share/"08_sad_song.it"
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

