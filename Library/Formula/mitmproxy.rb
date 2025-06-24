class Mitmproxy < Formula
  desc "Intercept, modify, replay, save HTTP/S traffic"
  homepage "https://mitmproxy.org"
  url "https://web.archive.org/web/20150909021206/https://mitmproxy.org/download/mitmproxy-0.13.tar.gz"
  sha256 "f35b90d836693dbb02a589ddee056bb4fdb7b679a1dfe230b0492216a8e3dcfa"
  head "https://github.com/mitmproxy/mitmproxy.git"

  bottle do
    cellar :any
    sha256 "b6f1e94bb7c2b6f78903c7223781d1956a27e841ac5b2602b7753be4093fd74c" => :el_capitan
    sha256 "6c98cac287bf19f150bdab659c532af1f9a45152eeb749650be51a95914cf2d1" => :yosemite
    sha256 "e9547ab49fa877da7e5e559cc4a4940a54a87cdd24f34694dbb12c266f2c4431" => :mavericks
  end

  option "with-pyamf", "Enable action message format (AMF) support for python"
  option "with-cssutils", "Enable beautification of CSS responses"

  depends_on "freetype"
  depends_on "openssl"
  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "protobuf" => :optional

  resource "backports.ssl_match_hostname" do
    url "https://pypi.python.org/packages/source/b/backports.ssl_match_hostname/backports.ssl_match_hostname-3.4.0.2.tar.gz"
    sha256 "07410e7fb09aab7bdaf5e618de66c3dac84e2e3d628352814dc4c37de321d6ae"
  end

  resource "blinker" do
    url "https://pypi.python.org/packages/source/b/blinker/blinker-1.4.tar.gz"
    sha256 "471aee25f3992bd325afa3772f1063dbdbbca947a041b8b89466dc00d606f8b6"
  end

  resource "certifi" do
    url "https://pypi.python.org/packages/source/c/certifi/certifi-2015.9.6.2.tar.gz"
    sha256 "dc3a2b2d9d1033dbf27586366ae61b9d7c44d8c3a6f29694ffcbb0618ea7aea6"
  end

  resource "cffi" do
    url "https://pypi.python.org/packages/source/c/cffi/cffi-1.2.1.tar.gz"
    sha256 "eab571deb0a152e2f53c404c08a94870a131526896cad08cd43bf86ce3771e3d"
  end

  resource "ConfigArgParse" do
    url "https://pypi.python.org/packages/source/C/ConfigArgParse/ConfigArgParse-0.9.3.tar.gz"
    sha256 "141c57112e1f8eb7e594a9820e95af897a7fa2d186cef5cff7e08cb3f7252829"
  end

  resource "cryptography" do
    url "https://pypi.python.org/packages/source/c/cryptography/cryptography-1.0.2.tar.gz"
    sha256 "d64cd491e91ddf642c643bea16532c2a2da2da054cca6df756edadd55a8bacca"
  end

  resource "enum34" do
    url "https://pypi.python.org/packages/source/e/enum34/enum34-1.0.4.tar.gz"
    sha256 "d3c19f26a6a34629c18c775f59dfc5dd595764c722b57a2da56ebfb69b94e447"
  end

  resource "hpack" do
    url "https://pypi.python.org/packages/source/h/hpack/hpack-1.1.0.tar.gz"
    sha256 "1a4832961ac0acb0d124d9db0bcb5ab44d61c8d8466c9a3b59d49aceeca91d11"
  end

  resource "html2text" do
    url "https://pypi.python.org/packages/source/h/html2text/html2text-2015.6.21.tar.gz"
    sha256 "5026fe0ca9600709b68ae70e086a1ca000c0af02e88ac8cb108030c6b5be8c6d"
  end

  resource "idna" do
    url "https://pypi.python.org/packages/source/i/idna/idna-2.0.tar.gz"
    sha256 "16199aad938b290f5be1057c0e1efc6546229391c23cea61ca940c115f7d3d3b"
  end

  resource "ipaddress" do
    url "https://pypi.python.org/packages/source/i/ipaddress/ipaddress-1.0.14.tar.gz"
    sha256 "226f4be44c6cb64055e23060848266f51f329813baae28b53dc50e93488b3b3e"
  end

  resource "lxml" do
    url "https://pypi.python.org/packages/source/l/lxml/lxml-3.4.4.tar.gz"
    sha256 "b3d362bac471172747cda3513238f115cbd6c5f8b8e6319bf6a97a7892724099"
  end

  resource "netlib" do
    url "https://pypi.python.org/packages/source/n/netlib/netlib-0.13.1.tar.gz"
    sha256 "f2b986ed2fa0125a88975d3f904a111c95b2925c3f553f7b1fc991f25bf4915b"
  end

  resource "passlib" do
    url "https://pypi.python.org/packages/source/p/passlib/passlib-1.6.5.tar.gz"
    sha256 "a83d34f53dc9b17aa42c9a35c3fbcc5120f3fcb07f7f8721ec45e6a27be347fc"
  end

  resource "pillow" do
    url "https://pypi.python.org/packages/source/P/Pillow/Pillow-2.9.0.tar.gz"
    sha256 "0f179d7e75e7c83b6341b9595ca1f394de7081484a9e352ad66d553a1c3daa29"
  end

  resource "pyasn1" do
    url "https://pypi.python.org/packages/source/p/pyasn1/pyasn1-0.1.8.tar.gz"
    sha256 "5d33be7ca0ec5997d76d29ea4c33b65c00c0231407fff975199d7f40530b8347"
  end

  resource "pycparser" do
    url "https://pypi.python.org/packages/source/p/pycparser/pycparser-2.14.tar.gz"
    sha256 "7959b4a74abdc27b312fed1c21e6caf9309ce0b29ea86b591fd2e99ecdf27f73"
  end

  resource "pyOpenSSL" do
    url "https://pypi.python.org/packages/source/p/pyOpenSSL/pyOpenSSL-0.15.1.tar.gz"
    sha256 "f0a26070d6db0881de8bcc7846934b7c3c930d8f9c79d45883ee48984bc0d672"
  end

  resource "pyparsing" do
    url "https://pypi.python.org/packages/source/p/pyparsing/pyparsing-2.0.3.tar.gz"
    sha256 "06e729e1cbf5274703b1f47b6135ed8335999d547f9d8cf048b210fb8ebf844f"
  end

  resource "pyperclip" do
    url "https://pypi.python.org/packages/source/p/pyperclip/pyperclip-1.5.13.zip"
    sha256 "b835b40605d5b24567176cf8686065fac523debbcc83fd643eba79c782817cee"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "tornado" do
    url "https://pypi.python.org/packages/source/t/tornado/tornado-4.2.1.tar.gz"
    sha256 "a16fcdc4f76b184cb82f4f9eaeeacef6113b524b26a2cb331222e4a7fa6f2969"
  end

  resource "urwid" do
    url "https://pypi.python.org/packages/source/u/urwid/urwid-1.3.0.tar.gz"
    sha256 "29f04fad3bf0a79c5491f7ebec2d50fa086e9d16359896c9204c6a92bc07aba2"
  end

  # Optional resources
  resource "pyamf" do
    url "https://pypi.python.org/packages/source/P/PyAMF/PyAMF-0.7.2.tar.gz"
    sha256 "3e39d43989f75a4d35f4c2a591d8163637f67eaf856bdae749bd8b64b1c1b672"
  end

  resource "cssutils" do
    url "https://pypi.python.org/packages/source/c/cssutils/cssutils-1.0.zip"
    sha256 "4504762f5d8800b98fa713749c00acfef8419826568f9363c490e45146a891af"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    ENV.append "CFLAGS", "-I#{MacOS.sdk_path}/System/Library/Frameworks/Tk.framework/Versions/8.5/Headers" unless MacOS::CLT.installed?

    resource("pillow").stage do
      inreplace "setup.py", "'brew', '--prefix'", "'#{HOMEBREW_PREFIX}/bin/brew', '--prefix'"
      system "python", *Language::Python.setup_install_args(libexec/"vendor")
    end

    res = %w[backports.ssl_match_hostname blinker certifi cffi ConfigArgParse
             cryptography enum34 hpack html2text idna ipaddress lxml netlib passlib
             pyasn1 pycparser pyOpenSSL pyparsing pyperclip six tornado urwid]

    res << "pyamf" if build.with? "pyamf"
    res << "cssutils" if build.with? "cssutils"

    res.each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    ENV["LANG"] = "en_US.UTF-8"
    system bin/"mitmproxy", "--version"
  end
end
