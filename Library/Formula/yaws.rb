class Yaws < Formula
  desc "Webserver for dynamic content (written in Erlang)"
  homepage "https://erlyaws.github.io/"
  url "https://github.com/klacke/yaws/archive/yaws-2.2.0.tar.gz"
  sha256 "39318736472c165d4aec769c89ac4edfe3cab7ff7759f32de0a4e699ef6c88e8"
  head "https://github.com/erlyaws/yaws.git"

  option "without-yapp", "Omit yaws applications"
  option "32-bit"

  depends_on :macos => :leopard

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "m4" => :build
  depends_on "erlang"

  # the default config expects these folders to exist
  skip_clean "var/log/yaws"
  skip_clean "lib/yaws/examples/ebin"
  skip_clean "lib/yaws/examples/include"

  def install
    if build.build_32_bit?
      ENV.append %w[CFLAGS LDFLAGS], "-arch #{Hardware::CPU.arch_32_bit}"
    end

    system "autoreconf", "-fvi"
    system "./configure", "--prefix=#{prefix}",
                          # Ensure pam headers are found on Xcode-only installs
                          "--with-extrainclude=#{MacOS.sdk_path}/usr/include/security"
    system "make", "install"

    if build.with? "yapp"
      cd "applications/yapp" do
        system "make"
        system "make", "install"
      end
    end

    # the default config expects these folders to exist
    (lib/"yaws/examples/ebin").mkpath
    (lib/"yaws/examples/include").mkpath

    (var/"log/yaws").mkpath
    (var/"yaws/www").mkpath
  end

  test do
    system bin/"yaws", "--version"
  end
end
