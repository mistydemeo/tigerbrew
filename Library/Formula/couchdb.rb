class Couchdb < Formula
  desc "CouchDB is a document database server"
  homepage "https://couchdb.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=/couchdb/source/1.7.2/apache-couchdb-1.7.2.tar.gz"
  sha256 "7b7c0db046ded544a587a8935d495610dd10f01a9cae3cd42cf88c5ae40bc431"

  head do
    url "https://git-wip-us.apache.org/repos/asf/couchdb.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on "autoconf-archive" => :build
    depends_on "pkg-config" => :build
    depends_on "help2man" => :build
  end

  depends_on "spidermonkey"
  depends_on "icu4c"
  depends_on "erlang"
  depends_on "curl" if MacOS.version <= :leopard

  def install
    # CouchDB >=1.3.0 supports vendor names and versioning
    # in the welcome message
    inreplace "etc/couchdb/default.ini.tpl.in" do |s|
      s.gsub! "%package_author_name%", "Tigerbrew"
      s.gsub! "%version%", pkg_version
    end

    if build.devel? || build.head?
      # workaround for the auto-generation of THANKS file which assumes
      # a developer build environment incl access to git sha
      touch "THANKS"
      system "./bootstrap"
    end

    system "./configure", "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}",
                          "--disable-init",
                          "--with-erlang=#{HOMEBREW_PREFIX}/lib/erlang/usr/include",
                          "--with-js-include=#{HOMEBREW_PREFIX}/include/js",
                          "--with-js-lib=#{HOMEBREW_PREFIX}/lib"
    system "make"
    system "make", "install"

    # Use our plist instead to avoid faffing with a new system user.
    (prefix+"Library/LaunchDaemons/org.apache.couchdb.plist").delete
    (lib+"couchdb/bin/couchjs").chmod 0755
    (var+"lib/couchdb").mkpath
    (var+"log/couchdb").mkpath
  end

  def post_install
    # default.ini is owned by CouchDB and marked not user-editable
    # and must be overwritten to ensure correct operation.
    if (etc/"couchdb/default.ini.default").exist?
      # but take a backup just in case the user didn't read the warning.
      mv etc/"couchdb/default.ini", etc/"couchdb/default.ini.old"
      mv etc/"couchdb/default.ini.default", etc/"couchdb/default.ini"
    end
  end

  plist_options :manual => "couchdb"

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
        <string>#{opt_bin}/couchdb</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    To test CouchDB run:
        curl http://127.0.0.1:5984/

    The reply should look like:
        {"couchdb":"Welcome","uuid":"....","version":"#{version}","vendor":{"version":"#{version}-1","name":"Tigerbrew"}}
    EOS
  end

  test do
    # ensure couchdb embedded spidermonkey vm works
    system "#{bin}/couchjs", "-h"
  end
end
