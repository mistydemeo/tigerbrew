class NumUtils < Formula
  desc "Programs for dealing with numbers from the command-line"
  homepage "http://suso.suso.org/programs/num-utils/"
  url "http://suso.suso.org/programs/num-utils/downloads/num-utils-0.5.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/n/num-utils/num-utils_0.5.orig.tar.gz"
  sha256 "03592760fc7844492163b14ddc9bb4e4d6526e17b468b5317b4a702ea7f6c64e"


  conflicts_with "normalize", :because => "both install `normalize` binaries"
  conflicts_with "crush-tools", :because => "both install an `range` binary"

  def install
    %w[average bound interval normalize numgrep numprocess numsum random range round].each do |p|
      system "pod2man", p, "#{p}.1"
      bin.install p
      man1.install "#{p}.1"
    end
  end

  test do
    assert_equal "2", pipe_output("#{bin}/average", "1\n2\n3\n").strip
  end
end
