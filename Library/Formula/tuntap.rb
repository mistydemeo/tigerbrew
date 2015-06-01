require "formula"

class Tuntap < Formula
  homepage 'http://tuntaposx.sourceforge.net/'

  # 20111101 dropped support for PowerPC, but still runs on 10.4
  # 20090913 is the last release that supports PowerPC at all.
  tag = Hardware::CPU.ppc? ? 'release_20090913' : 'release_20111101'
  url 'git://git.code.sf.net/p/tuntaposx/code', :tag => tag

  bottle do
    cellar :any
    sha256 "62f4775179574e59661badc00178cce7b334f24dc4f5a2cc06de5a0a618906f7" => :leopard_g3
    sha256 "d2ffdd7c5441e054152a8491cf378dc5fc7fb5ab1cab6eccc9b44ef7298f7f4b" => :leopard_altivec
  end

  depends_on UnsignedKextRequirement => [ :cask => "tuntap",
      :download => "http://sourceforge.net/projects/tuntaposx/files/tuntap/" ]

  # error: invalid conversion from 'errno_t (*)(__ifnet*, long unsigned int, void*)' to 'errno_t (*)(__ifnet*, u_int32_t, void*)'
  patch :DATA

  def install
    cd "tuntap"

    # Don't force archflags
    inreplace %w[src/tap/Makefile src/tun/Makefile] do |s|
      s.gsub! "-arch ppc -arch i386 -arch x86_64", ""
      s.gsub! "-Xlinker -kext", ""
    end

    ENV.j1 # to avoid race conditions (can't open: ../tuntap.o)
    system "make", "CC=#{ENV.cc}", "CCP=#{ENV.cxx}"
    kext_prefix.install "tun.kext", "tap.kext"
    prefix.install "startup_item/tap", "startup_item/tun"
  end

  def caveats; <<-EOS.undent
      In order for TUN/TAP network devices to work, the tun/tap kernel extensions
      must be installed by the root user:

        sudo cp -pR #{kext_prefix}/tap.kext /Library/Extensions/
        sudo cp -pR #{kext_prefix}/tun.kext /Library/Extensions/
        sudo chown -R root:wheel /Library/Extensions/tap.kext
        sudo chown -R root:wheel /Library/Extensions/tun.kext
        sudo touch /Library/Extensions/

      To load the extensions at startup, you have to install those scripts too:

        sudo cp -pR #{prefix}/tap /Library/StartupItems/
        sudo chown -R root:wheel /Library/StartupItems/tap
        sudo cp -pR #{prefix}/tun /Library/StartupItems/
        sudo chown -R root:wheel /Library/StartupItems/tun

      If upgrading from a previous version of tuntap, the old kernel extension
      will need to be unloaded before performing the steps listed above. First,
      check that no tunnel is being activated, disconnect them all and then unload
      the kernel extension:

        sudo kextunload -b foo.tun
        sudo kextunload -b foo.tap

    EOS
  end
end

__END__
diff --git a/tuntap/src/tuntap.cc b/tuntap/src/tuntap.cc
index 143d94a..d48d5c7 100644
--- a/tuntap/src/tuntap.cc
+++ b/tuntap/src/tuntap.cc
@@ -75,7 +75,7 @@ tuntap_if_output(ifnet_t ifp, mbuf_t m)
 }
 
 errno_t
-tuntap_if_ioctl(ifnet_t ifp, long unsigned int cmd, void *arg)
+tuntap_if_ioctl(ifnet_t ifp, uint32_t cmd, void *arg)
 {
 	if (ifp != NULL) {
 		tuntap_interface *ttif = (tuntap_interface *) ifnet_softc(ifp);
diff --git a/tuntap/src/tuntap.h b/tuntap/src/tuntap.h
index e025abd..c74394e 100644
--- a/tuntap/src/tuntap.h
+++ b/tuntap/src/tuntap.h
@@ -54,7 +54,7 @@ extern "C" {
 extern "C" {
 
 errno_t tuntap_if_output(ifnet_t ifp, mbuf_t m);
-errno_t tuntap_if_ioctl(ifnet_t ifp, long unsigned int cmd, void *arg);
+errno_t tuntap_if_ioctl(ifnet_t ifp, uint32_t cmd, void *arg);
 errno_t tuntap_if_set_bpf_tap(ifnet_t ifp, bpf_tap_mode mode, int (*cb)(ifnet_t, mbuf_t));
 errno_t tuntap_if_demux(ifnet_t ifp, mbuf_t m, char *header, protocol_family_t *proto);
 errno_t tuntap_if_framer(ifnet_t ifp, mbuf_t *m, const struct sockaddr *dest,
@@ -264,7 +264,7 @@ class tuntap_interface {
 
 		/* interface functions. friends and implementation methods */
 		friend errno_t tuntap_if_output(ifnet_t ifp, mbuf_t m);
-		friend errno_t tuntap_if_ioctl(ifnet_t ifp, long unsigned int cmd, void *arg);
+		friend errno_t tuntap_if_ioctl(ifnet_t ifp, uint32_t cmd, void *arg);
 		friend errno_t tuntap_if_set_bpf_tap(ifnet_t ifp, bpf_tap_mode mode,
 				int (*cb)(ifnet_t, mbuf_t));
 		friend errno_t tuntap_if_demux(ifnet_t ifp, mbuf_t m, char *header,
