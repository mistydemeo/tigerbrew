class Babeld < Formula
  desc "Loop-avoiding distance-vector routing protocol"
  homepage "http://www.pps.univ-paris-diderot.fr/~jch/software/babel/"
  url "http://www.pps.univ-paris-diderot.fr/~jch/software/files/babeld-1.6.2.tar.gz"
  sha256 "09de0d99684e95466f07be1eb22fa639c8820d8aaaa7a8db2a18a354cb3d0fb7"
  head "https://github.com/jech/babeld.git"


  def install
    system "make", "LDLIBS=''"
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    shell_output("#{bin}/babeld -I #{testpath}/test.pid -L #{testpath}/test.log", 1)
    expected = <<-EOS.undent
      Couldn't tweak forwarding knob.: Operation not permitted
      kernel_setup failed.
    EOS
    assert_equal expected, (testpath/"test.log").read
  end
end
