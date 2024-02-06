class Freetds < Formula
  desc "Libraries to talk to Microsoft SQL Server and Sybase databases"
  homepage "http://www.freetds.org/"
  url "https://www.freetds.org/files/stable/freetds-1.4.10.tar.gz"
  sha256 "4f58ee544c94a75263c9e71449ec9cf50be45c899243a4bdb73ba4cb96b8f038"

  bottle do
  end

  head do
    url "https://github.com/FreeTDS/freetds.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
    depends_on "libtool" => :build
  end

  option :universal
  option "with-msdblib", "Enable Microsoft behavior in the DB-Library API where it diverges from Sybase's"
  option "with-sybase-compat", "Enable close compatibility with Sybase's ABI, at the expense of other features"
  option "with-odbc-wide", "Enable odbc wide, prevent unicode - MemoryError's"
  option "with-krb5", "Enable Kerberos support"

  deprecated_option "enable-msdblib" => "with-msdblib"
  deprecated_option "enable-sybase-compat" => "with-sybase-compat"
  deprecated_option "enable-odbc-wide" => "with-odbc-wide"
  deprecated_option "enable-krb" => "with-krb5"

  depends_on "pkg-config" => :build
  depends_on "unixodbc"
  depends_on "openssl3"

  def install
    args = %W[
      --prefix=#{prefix}
      --with-tdsver=7.1
      --mandir=#{man}
      --with-openssl=#{Formula["openssl3"].opt_prefix}
      --with-unixodbc=#{Formula["unixodbc"].opt_prefix}
    ]

    # Translate formula's "--with" options to configuration script's "--enable"
    # options
    %w[msdblib sybase-compat odbc-wide krb5].each do |option|
      if build.with? option
        args << "--enable-#{option}"
      end
    end

    ENV.universal_binary if build.universal?

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    system "make"
    ENV.j1 # Or fails to install on multi-core machines
    system "make", "install"
  end

  test do
    system "#{bin}/tsql", "-C"
  end
end
