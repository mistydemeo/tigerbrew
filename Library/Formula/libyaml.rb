class Libyaml < Formula
  desc "YAML Parser"
  homepage "https://pyyaml.org/wiki/LibYAML"
  url "https://pyyaml.org/download/libyaml/yaml-0.2.5.tar.gz"
  mirror "https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz"
  sha256 "c642ae9b75fee120b2d96c712538bd2cf283228d2337df2cf2988e3c02678ef4"

  bottle do
    sha256 "1059dae2e830cee36f64e8f8de5f7afd0fb0ef5eb833437da8188ed7a73befb3" => :tiger_altivec
  end

  option :universal

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
