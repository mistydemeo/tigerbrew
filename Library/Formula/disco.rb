class Disco < Formula
  desc "Distributed computing framework based on the MapReduce paradigm"
  homepage "http://discoproject.org/"
  url "https://github.com/discoproject/disco/archive/0.5.4.tar.gz"
  sha256 "a1872b91fd549cea6e709041deb0c174e18d0e1ea36a61395be37e50d9df1f8f"

  bottle do
    cellar :any
    sha1 "f1a4e9775053971dac6ab3b183ebb13d6928c050" => :yosemite
    sha1 "286325ec178e1bd06a78127333c835a1bf5a2763" => :mavericks
    sha1 "da6e23c51a8ca6c353e83724746f0e11dba37a99" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "erlang"
  depends_on "libcmph"

  resource "simplejson" do
    url "https://files.pythonhosted.org/packages/af/92/51b417685abd96b31308b61b9acce7ec50d8e1de8fbc39a7fd4962c60689/simplejson-3.20.1.tar.gz"
    sha256 "e64139b4ec4f1f24c142ff7dcafe55a22b811a74d86d66560c8815687143037d"
  end

  resource "goldrush" do
    url "https://github.com/DeadZen/goldrush/archive/refs/tags/0.1.6.zip"
    sha256 "d10a4f593fb879275200693df29a8f08018c1e70d2b4f5258e1a35756dfc1313"
  end

  resource "bear" do
    url "https://github.com/boundary/bear/archive/refs/tags/0.8.1.zip"
    sha256 "cb2c6aabac2942e3d14fd900f820312b0e4a74252d61b9298e76c4443bf05e4d"
  end

  resource "meck" do
    url "https://github.com/eproxus/meck/archive/refs/tags/0.8.2.zip"
    sha256 "c6ba50da30d30e904067f9ea661028dbea3b33c4c5f7631c1fb893ac264f91ec"
  end

  # Modifies config for single-node operation
  patch :DATA

  def install
    ENV["PYTHONPATH"] = lib+"python2.7/site-packages"
    if MacOS.version <= :leopard
      resource("simplejson").stage { system "python", *Language::Python.setup_install_args(libexec/"vendor") }
    end

    inreplace "Makefile" do |s|
      s.change_make_var! "prefix", prefix
      s.change_make_var! "sysconfdir", etc
      s.change_make_var! "localstatedir", var
    end

    # Ignore warnings about erlang:now() deprecation in OTP 18
    inreplace "master/rebar.config", "warnings_as_errors,", ""

    # Disco's "rebar" build tool refuses to build unless it's in a git repo, so
    # make a dummy one
    system "git init && git add master/rebar && git commit -a -m 'dummy commit'"

    # rebar tries to clone goldrush, bear, and meck using git://github.com/ urls
    # which are no longer offered by github. Add these dependencies to the expected places.
    mkdir_p "master/deps"
    for dependency in ["goldrush", "bear", "meck"] do
      resource(dependency).verify_download_integrity(resource(dependency).fetch)
      resource(dependency).unpack("#{buildpath}/master/deps/#{dependency}")
    end

    # fix erlang 18 incompatibility in type name
    inreplace "master/src/worker_throttle.erl", "-opaque state() :: queue().", "-opaque state() :: queue:queue()."
    inreplace "master/src/worker_throttle.erl", "-spec throttle(queue()", "-spec throttle(queue:queue()"

    system "make"
    system "make", "install"
    prefix.install %w[contrib doc examples]

    # Fix the config file to point at the linked files, not in to cellar
    # This isn't ideal - if there's a settings.py file left over from a previous disco
    # installation, it'll issue an error
    inreplace "#{etc}/disco/settings.py" do |s|
      s.gsub!("Cellar/disco/"+version+"/", "")
    end

    bin.env_script_all_files(libexec+"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  def caveats
    <<-EOS.undent
      Please copy #{etc}/disco/settings.py to ~/.disco and edit it if necessary.
      The DDFS_*_REPLICA settings have been set to 1 assuming a single-machine install.
      Please see http://discoproject.org/doc/disco/start/install.html for further instructions.
    EOS
  end

  test do
    system "#{bin}/disco"
  end
end

__END__
diff -rupN disco-0.4.5/conf/gen.settings.sh my-edits/disco-0.4.5/conf/gen.settings.sh
--- disco-0.4.5/conf/gen.settings.sh  2013-03-28 12:21:30.000000000 -0400
+++ my-edits/disco-0.4.5/conf/gen.settings.sh 2013-04-10 23:10:00.000000000 -0400
@@ -23,8 +23,11 @@ DISCO_PORT = 8989
 # DISCO_PROXY_ENABLED = "on"
 # DISCO_HTTPD = "/usr/sbin/varnishd -a 0.0.0.0:\$DISCO_PROXY_PORT -f \$DISCO_PROXY_CONFIG -P \$DISCO_PROXY_PID -n/tmp -smalloc"

-DDFS_TAG_MIN_REPLICAS = 3
-DDFS_TAG_REPLICAS     = 3
-DDFS_BLOB_REPLICAS    = 3
+# Settings appropriate for single-node operation
+DDFS_TAG_MIN_REPLICAS = 1
+DDFS_TAG_REPLICAS     = 1
+DDFS_BLOB_REPLICAS    = 1
+
+DISCO_MASTER_HOST     = "localhost"

 EOF
