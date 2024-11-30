class Unixodbc < Formula
  desc "ODBC 3 connectivity for UNIX"
  homepage "http://www.unixodbc.org/"
  url "https://www.unixodbc.org/unixODBC-2.3.12.tar.gz"
  sha256 "f210501445ce21bf607ba51ef8c125e10e22dffdffec377646462df5f01915ec"

  bottle do
  end

  option :universal

  conflicts_with "virtuoso", :because => "Both install `isql` binaries."

  keg_only "Shadows system iODBC header files" if MacOS.version < :mavericks

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-gui=no"
    system "make", "install"
  end
end
