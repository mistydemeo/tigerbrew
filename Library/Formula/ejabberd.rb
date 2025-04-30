class Ejabberd < Formula
  desc "XMPP application server"
  homepage "https://www.ejabberd.im"
  url "https://github.com/processone/ejabberd/archive/refs/tags/16.12.tar.gz"
  sha256 "a7eeb9fe49ef141daab1be01838a7612dff9194a28c3dfc922cc691bb8c9b532"

  option "32-bit"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "rebar" => :build

  depends_on "erlang"
  depends_on "libyaml"
  depends_on "openssl3"

  # for CAPTCHA challenges
  depends_on "imagemagick" => :optional

  resource "p1_pam" do
    url "https://github.com/processone/epam/archive/refs/tags/1.0.0.zip"
    sha256 "6704010b14034881d8c60f52d1a82d8125f20cdf1e52a7113c838f1db6be7e81"
  end

  def install
    ENV["TARGET_DIR"] = ENV["DESTDIR"] = "#{lib}/ejabberd/erlang/lib/ejabberd-#{version}"
    ENV["MAN_DIR"] = man
    ENV["SBIN_DIR"] = sbin
    mkdir_p("deps/p1_pam")
    resource("p1_pam").verify_download_integrity(resource("p1_pam").fetch)
    resource("p1_pam").unpack("#{buildpath}/deps/p1_pam")

    if build.build_32_bit?
      ENV.append %w[CFLAGS LDFLAGS], "-arch #{Hardware::CPU.arch_32_bit}"
    end

    args = ["--prefix=#{prefix}",
            "--sysconfdir=#{etc}",
            "--localstatedir=#{var}",
            "--enable-pgsql",
            "--enable-mysql",
            "--enable-odbc",
            "--enable-pam"]

    # lager 3.2.1 uses the git protocol to try and clone its dependency
    # By 3.2.3 they switched to HTTPS, switch to the most recent minor release.
    inreplace "rebar.config", 'lager", {tag, "3.2.1', 'lager", {tag, "3.2.4'

    system "autoupdate"
    system "./autogen.sh"
    system "./configure", *args

    # Before Snow Leopard, the pam header files were in /usr/include/pam instead of /usr/include/security.
    # https://trac.macports.org/ticket/26127
    if MacOS.version <= :leopard
      inreplace "deps/p1_pam/configure", "security/pam_appl.h", "pam/pam_appl.h"
      inreplace "deps/p1_pam/configure.ac", "security/pam_appl.h", "pam/pam_appl.h"
      inreplace "deps/p1_pam/c_src/epam.c", "security/pam_appl.h", "pam/pam_appl.h"
    end

    system "make"
    system "make", "install"

    (etc+"ejabberd").mkpath
    (var+"lib/ejabberd").mkpath
    (var+"spool/ejabberd").mkpath
  end

  def caveats; <<-EOS.undent
    If you face nodedown problems, concat your machine name to:
      /private/etc/hosts
    after 'localhost'.
    EOS
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/sbin/ejabberdctl start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>EnvironmentVariables</key>
      <dict>
        <key>HOME</key>
        <string>#{var}/lib/ejabberd</string>
      </dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/ejabberdctl</string>
        <string>start</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}/lib/ejabberd</string>
    </dict>
    </plist>
    EOS
  end
end
