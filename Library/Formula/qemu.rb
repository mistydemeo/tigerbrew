class Qemu < Formula
  homepage "http://wiki.qemu.org"
  # 2.2.1 is the last version to work pre-10.6
  # See: https://github.com/mistydemeo/tigerbrew/issues/523
  url "http://wiki.qemu-project.org/download/qemu-2.2.1.tar.bz2"
  sha256 "4617154c6ef744b83e10b744e392ad111dd351d435d6563ce24d8da75b1335a0"
  head "git://git.qemu-project.org/qemu.git"

  bottle do
    sha1 "becc370764c6a1408112cd0bfd534842591cdda5" => :yosemite
    sha1 "fbd6ec4d831ecf814a47a4dd1b0811223ecef5be" => :mavericks
    sha1 "27cc527a607c4c9d818e78eba2a0bd55ad5e52b9" => :mountain_lion
  end

  depends_on "make" => :build if MacOS.version < :leopard
  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "gnutls"
  depends_on "glib"
  depends_on "pixman"
  depends_on "vde" => :optional
  depends_on "sdl" => :optional
  depends_on "gtk+" => :optional
  depends_on "libssh2" => :optional

  # 3.2MB working disc-image file hosted on upstream's servers for people to use to test qemu functionality.
  resource "armtest" do
    url "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
    sha256 "4b4c2dce4c055f0a2adb93d571987a3d40c96c6cbfd9244d19b9708ce5aea454"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"

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
      --disable-bsd-user
      --disable-guest-agent
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
