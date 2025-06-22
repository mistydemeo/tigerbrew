class Mycli < Formula
  desc "CLI for MySQL with auto-completion and syntax highlighting"
  homepage "https://www.mycli.net/"
  url "https://pypi.python.org/packages/source/m/mycli/mycli-1.4.0.tar.gz"
  sha256 "117f65f4825c621e0b6fde85a3fb209366a4477cc4a521a60ede230c53843015"

  bottle do
    cellar :any_skip_relocation
    sha256 "e6ee7b534fb8e391657bc6933e4efac4e2b7f9eaedec2e780127b42aa219e7a5" => :el_capitan
    sha256 "88eddf1ec8b8b9ea7762750c996709e289c967eddc40aca019657dc7830fc12a" => :yosemite
    sha256 "91ef6466e92b6c8ab1c9dada94706f4eff720caced926958df5bfb07bf02ad5c" => :mavericks
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "openssl"

  resource "click" do
    url "https://pypi.python.org/packages/source/c/click/click-4.1.tar.gz"
    sha256 "e339ed09f25e2145314c902a870bc959adcb25653a2bd5cc1b48d9f56edf8ed8"
  end

  resource "configobj" do
    url "https://pypi.python.org/packages/source/c/configobj/configobj-5.0.6.tar.gz"
    sha256 "a2f5650770e1c87fb335af19a9b7eb73fc05ccf22144eb68db7d00cd2bcb0902"
  end

  resource "prompt_toolkit" do
    url "https://pypi.python.org/packages/source/p/prompt_toolkit/prompt_toolkit-0.46.tar.gz"
    sha256 "1aa25cb9772e1e27d12f7920b5a514421ab763231067119bbd2f8b1574b409fb"
  end

  resource "Pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.0.2.tar.gz"
    sha256 "7320919084e6dac8f4540638a46447a3bd730fca172afc17d2c03eed22cf4f51"
  end

  resource "PyMySQL" do
    url "https://pypi.python.org/packages/source/P/PyMySQL/PyMySQL-0.6.6.tar.gz"
    sha256 "c18e62ca481c5ada6c7bee1b81fc003d6ceae932c878db384cd36808010b3774"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.9.0.tar.gz"
    sha256 "e24052411fc4fbd1f672635537c3fc2330d9481b18c0317695b46259512c91d5"
  end

  resource "sqlparse" do
    url "https://pypi.python.org/packages/source/s/sqlparse/sqlparse-0.1.16.tar.gz"
    sha256 "678c6c36ca4b01405177da8b84eecf92ec92c9f6c762396c965bb5d305f20f81"
  end

  resource "wcwidth" do
    url "https://pypi.python.org/packages/source/w/wcwidth/wcwidth-0.1.4.tar.gz"
    sha256 "906d3123045d77027b49fe912458e1a1e1d6ca1a51558a4bd9168d143b129d2b"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    %w[click prompt_toolkit PyMySQL sqlparse Pygments wcwidth six configobj].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    system bin/"mycli", "--help"
  end
end
