class Postgresql < Formula
  desc "Object-relational database system"
  homepage "https://www.postgresql.org/"
  url "https://ftp.postgresql.org/pub/source/v15.4/postgresql-15.4.tar.bz2"
  sha256 "baec5a4bdc4437336653b6cb5d9ed89be5bd5c0c58b94e0becee0a999e63c8f9"
  revision 1

  bottle do
    sha256 "ed31af40b9f8b7c73afac0004061fca1e3c18a15bb5b5a7b756e8101c379a478" => :tiger_altivec
  end

  option "32-bit"
  option "without-perl", "Build without Perl support"
  option "without-tcl", "Build without Tcl support"
  option "with-dtrace", "Build with DTrace support" if MacOS.version >= :leopard

  deprecated_option "no-perl" => "without-perl"
  deprecated_option "no-tcl" => "without-tcl"
  deprecated_option "enable-dtrace" => "with-dtrace"
  deprecated_option "with-python" => "with-python3"

  depends_on "openssl3"
  depends_on "readline"
  depends_on "libxml2"
  depends_on "libxslt"
  depends_on "make" => :build if MacOS.version < :leopard # GNU make 3.81 or newer is required
  depends_on "perl" if build.with? "perl"
  depends_on :python3 => :optional
  depends_on "zlib"

  conflicts_with "postgres-xc",
    :because => "postgresql and postgres-xc install the same binaries."

  def install
    ENV.libxml2 if MacOS.version >= :snow_leopard
    # Breaks build and threading test during configuration
    ENV.minimal_optimization if ENV.compiler == :gcc_4_0
    # Build breaks passing -w
    ENV.enable_warnings if ENV.compiler == :gcc_4_0

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{share}/#{name}
      --docdir=#{doc}
      --with-bonjour
      --with-gssapi
      --with-ldap
      --with-openssl
      --with-pam
      --with-libxml
      --with-libxslt
    ]

    args << "--with-python" if build.with? "python3"
    args << "--with-perl" if build.with? "perl"

    # The CLT is required to build Tcl support on 10.7 and 10.8 because
    # tclConfig.sh is not part of the SDK
    if build.with?("tcl") && (MacOS.version >= :mavericks || MacOS::CLT.installed?)
      args << "--with-tcl"

      if File.exist?("#{MacOS.sdk_path}/usr/lib/tclConfig.sh")
        args << "--with-tclconfig=#{MacOS.sdk_path}/usr/lib"
      end
    end

    args << "--enable-dtrace" if build.with? "dtrace"
    args << "--with-uuid=e2fs"

    if build.build_32_bit?
      ENV.append %w[CFLAGS LDFLAGS], "-arch #{Hardware::CPU.arch_32_bit}"
    end

    system "./configure", *args
    system make_path, "install-world"
  end

  def post_install
    unless File.exist? "#{var}/postgres"
      system "#{bin}/initdb", "#{var}/postgres"
    end
  end

  def caveats; <<-EOS.undent
    If builds of PostgreSQL are failing and you have a prior version installed,
    you may need to remove the previous version first. See:
      https://github.com/Homebrew/homebrew/issues/2510

    To migrate existing data from a previous major version (pre-15.x) of PostgreSQL, see:
      https://www.postgresql.org/docs/15/upgrading.html
    EOS
  end

  plist_options :manual => "postgres -D #{HOMEBREW_PREFIX}/var/postgres"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/postgres</string>
        <string>-r</string>
        <string>#{var}/postgres/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres/server.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath/"test"
  end
end
