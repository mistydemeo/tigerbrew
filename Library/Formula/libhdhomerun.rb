class Libhdhomerun < Formula
  desc "C library for controlling SiliconDust HDHomeRun TV tuners"
  homepage "https://www.silicondust.com/support/downloads/linux/"
  url "https://download.silicondust.com/hdhomerun/libhdhomerun_20150406.tgz"
  sha256 "fa6da8ab4461bca6cd852c41ba98bad3b58235477ed64cd96fb27aa3cea67d5a"


  def install
    system "make"
    bin.install "hdhomerun_config"
    lib.install "libhdhomerun.dylib"
    include.install Dir["hdhomerun*.h"]
  end

  test do
    # Devices may be found or not found, with differing return codes
    discover = pipe_output("#{bin}/hdhomerun_config discover")
    outputs = ["no devices found", "hdhomerun device", "found at"]
    assert outputs.any? { |x| discover.include? x }
  end
end
