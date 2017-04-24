class Qemu < Formula
  desc "x86 and PowerPC Emulator"
  homepage "http://wiki.qemu.org"
  head "git://git.qemu-project.org/qemu.git"

  stable do
    url "http://wiki.qemu-project.org/download/qemu-2.4.0.1.tar.bz2"
    sha256 "ecfe8b88037e41e817d72c460c56c6a0b573d540d6ba38b162d0de4fd22d1bdb"

    # Upstream patch to "fix" pre-10.5 file handler UI... by removing the UI.
    # The UI is gone on all OS X versions as of qemu 2.5.0; this patch can be removed then.
    patch do
      url "https://github.com/qemu/qemu/commit/365d7f3c7aacc789ead96b8eeb5ba5b0a8d93d48.patch"
      sha256 "0b32b6af97d7079302ee4a76699ffe232b4121f5488079b8e757161170cea0d9"
    end
  end

  bottle do
    sha256 "c6bf8ef38e8af71b00a906a4578bd180d91dce2f3c2f092818690b52bfaac895" => :el_capitan
    sha256 "36e3cee1a950d0877d6120b4e7603ddd96e506af54e72337276e5d931e8c40dc" => :yosemite
    sha256 "043f1c5b577fdfbaac516bc1ca909dee089cd591fd018b68c1298ab859170ef9" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "libtool" => :build
  depends_on "jpeg"
  depends_on "gnutls"
  depends_on "glib"
  depends_on "libutil" if MacOS.version < :leopard
  depends_on "pixman"
  depends_on "vde" => :optional
  depends_on "sdl" => :optional
  depends_on "gtk+" => :optional
  depends_on "libssh2" => :optional

  fails_with :gcc_4_0
  fails_with :gcc

  # 3.2MB working disc-image file hosted on upstream's servers for people to use to test qemu functionality.
  resource "armtest" do
    url "http://wiki.qemu.org/download/arm-test-0.2.tar.gz"
    sha256 "4b4c2dce4c055f0a2adb93d571987a3d40c96c6cbfd9244d19b9708ce5aea454"
  end

  def install
    ENV["LIBTOOL"] = "glibtool"

    # Needed for certain stdint macros on 10.4
    ENV.append_to_cflags "-D__STDC_CONSTANT_MACROS" if MacOS.version < :leopard

    args = %W[
      --prefix=#{prefix}
      --cc=#{ENV.cc}
      --host-cc=#{ENV.cc}
      --enable-cocoa
      --disable-bsd-user
      --disable-guest-agent
    ]

    # qemu will try to build 64-bit on 64-bit hardware, but we might not want that
    args << "--cpu=#{Hardware::CPU.arch_32_bit}" unless MacOS.prefer_64_bit?
    args << (build.with?("sdl") ? "--enable-sdl" : "--disable-sdl")
    args << (build.with?("vde") ? "--enable-vde" : "--disable-vde")
    args << (build.with?("gtk+") ? "--enable-gtk" : "--disable-gtk")
    args << (build.with?("libssh2") ? "--enable-libssh2" : "--disable-libssh2")

    system "./configure", *args
    system "make", "V=1", "install"
  end

  test do
    resource("armtest").stage testpath
    assert_match /file format: raw/, shell_output("#{bin}/qemu-img info arm_root.img")
  end
end
