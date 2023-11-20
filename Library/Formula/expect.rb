class Expect < Formula
  desc "Program that can automate interactive applications"
  homepage "https://core.tcl-lang.org/expect/index"
  url "https://prdownloads.sourceforge.net/project/expect/Expect/5.45.4/expect5.45.4.tar.gz"
  sha256 "49a7da83b0bdd9f46d04a04deec19c7767bb9a323e40c4781f89caf760b92c34"
  license :public_domain

  bottle do
  end

  depends_on "tcl-tk"

  conflicts_with "ircd-hybrid", because: "both install an `mkpasswd` binary"

  # Fix a segfault in exp_getptymaster()
  # Commit taken from Iain Sandoe's branch at https://github.com/iains/darwin-expect
  patch do
    url "https://github.com/iains/darwin-expect/commit/2a98bd855e9bf2732ba6ddbd490b748d5668eeb0.patch?full_index=1"
    sha256 "deb83cfa2475b532c4e63b0d67e640a4deac473300dd986daf650eba63c4b4c0"
  end

  def install
    ENV.enable_warnings if ENV.compiler == :gcc_4_0
    tcltk = Formula["tcl-tk"]
    args = %W[
      --prefix=#{prefix}
      --exec-prefix=#{prefix}
      --mandir=#{man}
      --enable-shared
      --with-tcl=#{tcltk.opt_lib}
    ]

    args << "--enable-64bit" if MacOS.prefer_64_bit?

    system "./configure", *args
    system "make"
    system "make", "install"
    lib.install_symlink Dir[lib/"expect*/libexpect*"]
    bin.env_script_all_files libexec/"bin",
                             PATH:       "#{tcltk.opt_bin}:$PATH",
                             TCLLIBPATH: lib.to_s
    # "expect" is already linked to "tcl-tk", no shim required
    bin.install libexec/"bin/expect"
  end

  test do
    assert_match "works", shell_output("echo works | #{bin}/timed-read 1")
    assert_equal "", shell_output("{ sleep 3; echo fails; } | #{bin}/timed-read 1 2>&1")
    assert_match "Done", pipe_output("#{bin}/expect", "exec true; puts Done")
  end
end
