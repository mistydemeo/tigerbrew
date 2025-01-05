class Autossh < Formula
  desc "Automatically restart SSH sessions and tunnels"
  homepage "https://www.harding.motd.ca/autossh/"
  url "https://www.harding.motd.ca/autossh/autossh-1.4g.tgz"
  mirror "https://deb.debian.org/debian/pool/main/a/autossh/autossh_1.4g.orig.tar.gz"
  sha256 "5fc3cee3361ca1615af862364c480593171d0c54ec156de79fc421e31ae21277"

  bottle do
    cellar :any_skip_relocation
    sha256 "eac52de293d3a1a3afed76bebb8cb5acac07f49f90c81b8f22c0d3437ac36fe4" => :tiger_altivec
  end

  patch :DATA

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
    bin.install "rscreen"
  end
end


__END__
diff --git a/rscreen b/rscreen
index f0bbced..ce232c3 100755
--- a/rscreen
+++ b/rscreen
@@ -23,4 +23,4 @@ fi
 #AUTOSSH_PATH=/usr/local/bin/ssh
 export AUTOSSH_POLL AUTOSSH_LOGFILE AUTOSSH_DEBUG AUTOSSH_PATH AUTOSSH_GATETIME AUTOSSH_PORT
 
-autossh -M 20004 -t $1 "screen -e^Zz -D -R"
+autossh -M 20004 -t $1 "screen -D -R"
