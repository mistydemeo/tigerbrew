class Qd < Formula
  desc "C++/Fortran-90 double-double and quad-double package"
  homepage "http://crd.lbl.gov/~dhbailey/mpdist/"
  url "http://crd.lbl.gov/~dhbailey/mpdist/qd-2.3.15.tar.gz"
  sha256 "17d7ed554613e4c17ac18670ef49d114ba706a63d735d72032b63a8833771ff7"


  depends_on :fortran => :recommended

  def install
    args = ["--disable-dependency-tracking", "--enable-shared", "--prefix=#{prefix}"]
    args << "--enable-fortran=no" if build.without? :fortran
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/qd-config --configure-args")
  end
end
