class UserspaceRcu < Formula
  desc "Library for userspace RCU (read-copy-update)"
  homepage "https://lttng.org/urcu"
  url "https://www.lttng.org/files/urcu/userspace-rcu-0.8.7.tar.bz2"
  sha256 "b523f22c4726ca6bb77a77d258e76d8c33c89724433bd65313024b98e55c4295"


  def install
    args = ["--disable-dependency-tracking",
            "--disable-silent-rules",
            "--prefix=#{prefix}"]
    # workaround broken upstream detection of build platform
    # marked as wontfix: http://bugs.lttng.org/issues/578#note-1
    if MacOS.prefer_64_bit?
      args << "--build=#{Hardware::CPU.arch_64_bit}"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    cp_r "#{doc}/examples", testpath
    system "make", "-C", "examples"
  end
end
