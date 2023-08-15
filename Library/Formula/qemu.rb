class Qemu < Formula
  desc "x86 and PowerPC Emulator"
  homepage "http://wiki.qemu.org"
  url "https://download.qemu.org/qemu-2.3.1.tar.bz2"
  sha256 "661d029809421cae06b4b1bc74ac0e560cb4ed47c9523c676ff277fa26dca15f"

  depends_on "make" => :build if MacOS.version < :leopard
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "glib"
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "pixman"
  depends_on "vde" => :optional
  depends_on "sdl" => :optional
  depends_on "gtk+" => :optional
  depends_on "libssh2" => :optional

  # 3.2MB working disc-image file hosted on upstream's servers for people to use to test qemu functionality.
  resource "armtest" do
    url "https://www.nongnu.org/qemu/arm-test-0.2.tar.gz"
    sha256 "4b4c2dce4c055f0a2adb93d571987a3d40c96c6cbfd9244d19b9708ce5aea454"
  end

  patch do
    # Portability fix - qemu binaries exit with "qobject/qjson.c:69: failed assertion `obj != NULL'" error
    # https://lists.gnu.org/archive/html/qemu-devel/2016-11/msg04186.html
    url "https://gitlab.com/qemu-project/qemu/-/commit/043b5a49516f5037430e7864e23fc2fdd39f2b10.diff"
    sha256 "db0419e2875a8057580c6b8d18938e6fff300b964b68d90ea77c0c237c582d67"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"
    # Need to tell ar(1) to generate a table of contents otherwise ld(1) errors
    # ld: in dtc/libfdt/libfdt.a, archive has no table of contents
    ENV["ARFLAGS"] = "srv" if MacOS.version == :leopard

    if MacOS.version < :leopard
      # Needed for certain stdint macros on 10.4
      ENV.append_to_cflags "-D__STDC_CONSTANT_MACROS"

      # Make 3.80 does not support the `or` operator and has trouble evaluating `unnest-vars`
      # See https://github.com/mistydemeo/tigerbrew/pull/496
      ENV["MAKE"] = make_path
    end

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --disable-vnc-tls
    ]

    # Cocoa UI uses features that require 10.5 or newer
    if MacOS.version > :tiger
      args << "--enable-cocoa"
    else
      args << "--disable-cocoa"
    end

    # qemu will try to build 64-bit on 64-bit hardware, but we might not want that
    args << "--cpu=#{Hardware::CPU.arch_32_bit}" unless MacOS.prefer_64_bit?
    args << (build.with?("sdl") ? "--enable-sdl" : "--disable-sdl")
    args << (build.with?("vde") ? "--enable-vde" : "--disable-vde")
    args << (build.with?("gtk+") ? "--enable-gtk" : "--disable-gtk")
    args << (build.with?("libssh2") ? "--enable-libssh2" : "--disable-libssh2")

    system "./configure", *args
    make "V=1", "install"
  end

  test do
    resource("armtest").stage testpath
    assert_match /file format: raw/, shell_output("#{bin}/qemu-img info arm_root.img")
  end
end
