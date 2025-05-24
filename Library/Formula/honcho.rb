class Honcho < Formula
  desc "Python clone of Foreman, for managing Procfile-based applications"
  homepage "https://github.com/nickstenning/honcho"
  url "https://github.com/nickstenning/honcho/archive/v0.6.6.tar.gz"
  sha256 "02703190e9775c899045e25e7f5b5b1a3b3ec1a4720d6b85a50da680f7f750c7"


  def install
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"Procfile").write <<-EOS.undent
      talk: echo $MY_VAR
    EOS
    (testpath/".env").write <<-EOS.undent
      MY_VAR=hi
    EOS
    assert_match /talk\.\d+ | hi/, `#{bin}/honcho start`
  end
end
