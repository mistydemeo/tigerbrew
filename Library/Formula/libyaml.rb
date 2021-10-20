class Libyaml < Formula
  desc "YAML Parser"
  homepage "http://pyyaml.org/wiki/LibYAML"
  url "http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/liby/libyaml/libyaml_0.1.6.orig.tar.gz"
  sha256 "7da6971b4bd08a986dd2a61353bc422362bd0edcc67d7ebaac68c95f74182749"
  revision 1

  bottle do
    cellar :any
    sha256 "557b32dbf6e6798972e6f9594a91cca044f90f92f410e0eb3ebcbee199f781aa" => :el_capitan
    sha1 "fe12271b6ad73806e26dd5e1c7d9090c739361a1" => :yosemite
    sha1 "c1db85f1e26699b0788cea8383fba127cfb4c83b" => :mavericks
    sha1 "5b2af750962a1cdc36384f49d2fe96b0f00d5fda" => :mountain_lion
  end

  option :universal

  # address CVE-2014-9130
  # https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-9130
  patch do
    url "https://git.g77k.com/supercatexpert/luna-yocto-meta-openembedded/-/raw/a3fd44bd1cba2ae55226b6cabec18347473197f4/meta-oe/recipes-support/libyaml/files/libyaml-CVE-2014-9130.patch"
    sha256 "c8a9122a40ae04ce96e77f006c297039f4707381c1e4ada8442dc837323e8bd1"
  end

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <yaml.h>

      int main()
      {
        yaml_parser_t parser;
        yaml_parser_initialize(&parser);
        yaml_parser_delete(&parser);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lyaml", "-o", "test"
    system "./test"
  end
end
