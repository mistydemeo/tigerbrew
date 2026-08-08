class Ejabberd < Formula
  desc "XMPP application server"
  homepage "https://www.ejabberd.im"
  url "https://github.com/processone/ejabberd/archive/refs/tags/25.04.tar.gz"
  sha256 "54beae3e7729fdaab1d578a9d59046f31d8ce31c851ae5aca9532821ff22cb45"

  depends_on :macos => :snow_leopard

  depends_on "autoconf" => :build
  depends_on "rebar3" => :build
  depends_on "erlang"
  depends_on "openssl3"

  # for CAPTCHA challenges
  depends_on "imagemagick" => :optional

  resource "epam" do
    url "https://github.com/processone/epam/archive/refs/tags/1.0.14.zip"
    sha256 "e876d7c8fc26345419b42291b631d6ddd1f45db27eb6e8cdd8203fabd6436b99"
  end

  def install
    inreplace "Makefile.in", "DEPS:=$(sort $(shell QUIET=1 $(REBAR) $(LISTDEPS) | $(SED) -ne $(DEPSPATTERN) ))", "DEPS:=base64url cache_tab eimp epam ezlib fast_tls fast_xml fast_yaml idna jiffy jose luerl mqtree p1_acme p1_mysql p1_oauth2 p1_pgsql p1_utils pkix stringprep stun unicode_util_compat xmpp yconf"

    mkdir_p("_build/default/lib/epam")
    resource("epam").verify_download_integrity(resource("epam").fetch)
    resource("epam").unpack("#{buildpath}/_build/default/lib/epam")

    args = ["--prefix=#{prefix}",
            "--sysconfdir=#{etc}",
            "--localstatedir=#{var}",
            "--enable-pgsql",
            "--enable-mysql",
            "--enable-odbc",
            "--enable-pam"]

    system "./autogen.sh"
    system "./configure", *args

    if MacOS.version < :snow_leopard
      inreplace "_build/default/lib/epam/configure", "security/pam_appl.h", "pam/pam_appl.h"
      inreplace "_build/default/lib/epam/configure.ac", "security/pam_appl.h", "pam/pam_appl.h"
      inreplace "_build/default/lib/epam/c_src/epam.c", "security/pam_appl.h", "pam/pam_appl.h"
    end

    system "make"
    system "make", "install"

  end
end
