class FbAdb < Formula
  desc "Shell for Android devices that does much of what adb does and more"
  homepage "https://github.com/facebook/fb-adb"
  url "https://github.com/facebook/fb-adb/archive/1.4.4.tar.gz"
  sha256 "c712cde3d4bfc16f8ea7da9a56d3cf567b8b9f1ae3c6c6bb052c95308b5752d9"


  depends_on "android-ndk" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "pkg-config" => :build
  depends_on "android-sdk"

  def install
    ENV["ANDROID_NDK"] = Formula["android-ndk"].opt_prefix

    system "./autogen.sh"

    mkdir "build" do
      system "../configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
  end

  def post_install
    system "echo", "Y", "|", "android", "update", "sdk", "--no-ui", "--filter", "platform-tools"
  end

  test do
    system "#{bin}/fb-adb", "devices"
    system "#{bin}/fb-adb", "kill-server"
    system "#{bin}/fb-adb", "start-server"
  end
end
