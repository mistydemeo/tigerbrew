class Nginx < Formula
  desc "HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server"
  homepage "http://nginx.org/"
  url "https://nginx.org/download/nginx-1.25.2.tar.gz"
  sha256 "05dd6d9356d66a74e61035f2a42162f8c754c97cf1ba64e7a801ba158d6c0711"
  head "http://hg.nginx.org/nginx/", :using => :hg
  revision 1

  bottle do
    sha256 "c2640340f79102c0bbe1db54e8cb280149e88b71a8378dce6ddb2fe10ca2b733" => :tiger_altivec
  end

  env :userpaths

  # Before submitting more options to this formula please check they aren't
  # already in Homebrew/homebrew-nginx/nginx-full:
  # https://github.com/Homebrew/homebrew-nginx/blob/master/nginx-full.rb
  option "with-passenger", "Compile with support for Phusion Passenger module"
  option "with-webdav", "Compile with support for WebDAV module"
  option "with-debug", "Compile with support for debug log"
  option "with-http3", "Compile with support for HTTP/3 module"
  option "with-gunzip", "Compile with support for gunzip module"

  depends_on "pcre2"
  depends_on "passenger" => :optional
  depends_on "openssl3" => :recommended
  depends_on "libressl" => :optional
  depends_on "zlib"

  def install
    # Changes default port to 8080
    inreplace "conf/nginx.conf", "listen       80;", "listen       8080;"
    inreplace "conf/nginx.conf", "    #}\n\n}", "    #}\n    include servers/*;\n}"

    pcre = Formula["pcre2"]
    openssl = Formula["openssl3"]
    libressl = Formula["libressl"]
    zlib = Formula["zlib"]

    if build.with? "libressl"
      cc_opt = "-I#{pcre.include} -I#{libressl.include} -I#{zlib.include}"
      ld_opt = "-L#{pcre.lib} -L#{libressl.lib} -L#{zlib.lib}"
    else
      cc_opt = "-I#{pcre.include} -I#{openssl.include} -I#{zlib.include}"
      ld_opt = "-L#{pcre.lib} -L#{openssl.lib} -L#{zlib.lib}"
    end

    args = %W[
      --prefix=#{prefix}
      --with-http_ssl_module
      --with-pcre
      --sbin-path=#{bin}/nginx
      --with-cc-opt=#{cc_opt}
      --with-ld-opt=#{ld_opt}
      --conf-path=#{etc}/nginx/nginx.conf
      --pid-path=#{var}/run/nginx.pid
      --lock-path=#{var}/run/nginx.lock
      --http-client-body-temp-path=#{var}/run/nginx/client_body_temp
      --http-proxy-temp-path=#{var}/run/nginx/proxy_temp
      --http-fastcgi-temp-path=#{var}/run/nginx/fastcgi_temp
      --http-uwsgi-temp-path=#{var}/run/nginx/uwsgi_temp
      --http-scgi-temp-path=#{var}/run/nginx/scgi_temp
      --http-log-path=#{var}/log/nginx/access.log
      --error-log-path=#{var}/log/nginx/error.log
      --with-http_gzip_static_module
      --with-http_v2_module
    ]

    if build.with? "passenger"
      nginx_ext = `#{Formula["passenger"].opt_bin}/passenger-config --nginx-addon-dir`.chomp
      args << "--add-module=#{nginx_ext}"
    end

    args << "--with-http_dav_module" if build.with? "webdav"
    args << "--with-debug" if build.with? "debug"
    args << "--with-http_gunzip_module" if build.with? "gunzip"
    args << "--with-http_v3_module" if build.with? "http3"

    if build.head?
      system "./auto/configure", *args
    else
      system "./configure", *args
    end

    system "make", "install"
    if build.head?
      man8.install "docs/man/nginx.8"
    else
      man8.install "man/nginx.8"
    end

    (etc/"nginx/servers").mkpath
    (var/"run/nginx").mkpath
  end

  def post_install
    # nginx's docroot is #{prefix}/html, this isn't useful, so we symlink it
    # to #{HOMEBREW_PREFIX}/var/www. The reason we symlink instead of patching
    # is so the user can redirect it easily to something else if they choose.
    html = prefix/"html"
    dst  = var/"www"

    if dst.exist?
      html.rmtree
      dst.mkpath
    else
      dst.dirname.mkpath
      html.rename(dst)
    end

    prefix.install_symlink dst => "html"

    # for most of this formula's life the binary has been placed in sbin
    # and Homebrew used to suggest the user copy the plist for nginx to their
    # ~/Library/LaunchAgents directory. So we need to have a symlink there
    # for such cases
    if rack.subdirs.any? { |d| d.join("sbin").directory? }
      sbin.install_symlink bin/"nginx"
    end
  end

  def passenger_caveats; <<-EOS.undent
    To activate Phusion Passenger, add this to #{etc}/nginx/nginx.conf, inside the 'http' context:
      passenger_root #{Formula["passenger"].opt_libexec}/src/ruby_supportlib/phusion_passenger/locations.ini;
      passenger_ruby /usr/bin/ruby;
    EOS
  end

  def caveats
    s = <<-EOS.undent
    Docroot is: #{var}/www

    The default port has been set in #{etc}/nginx/nginx.conf to 8080 so that
    nginx can run without sudo.

    nginx will load all files in #{etc}/nginx/servers/.
    EOS
    s << "\n" << passenger_caveats if build.with? "passenger"
    s
  end

  plist_options :manual => "nginx"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/nginx</string>
            <string>-g</string>
            <string>daemon off;</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end

  test do
    (testpath/"nginx.conf").write <<-EOS
      worker_processes 4;
      error_log #{testpath}/error.log;
      pid #{testpath}/nginx.pid;

      events {
        worker_connections 1024;
      }

      http {
        client_body_temp_path #{testpath}/client_body_temp;
        fastcgi_temp_path #{testpath}/fastcgi_temp;
        proxy_temp_path #{testpath}/proxy_temp;
        scgi_temp_path #{testpath}/scgi_temp;
        uwsgi_temp_path #{testpath}/uwsgi_temp;

        server {
          listen 8080;
          root #{testpath};
          access_log #{testpath}/access.log;
          error_log #{testpath}/error.log;
        }
      }
    EOS
    system "#{bin}/nginx", "-t", "-c", testpath/"nginx.conf"
  end
end
