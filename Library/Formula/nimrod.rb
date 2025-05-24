class Nimrod < Formula
  desc "Statically typed, imperative programming language"
  homepage "http://nim-lang.org/"
  url "http://nim-lang.org/download/nim-0.11.2.tar.xz"
  sha256 "5640e364d8bacec830f016daf3d4427911c48cebf962724ec903fea5d5a7a419"
  head "https://github.com/Araq/Nim.git", :branch => "devel"


  def install
    if build.head?
      system "/bin/sh", "bootstrap.sh"
    else
      system "/bin/sh", "build.sh"
    end
    system "/bin/sh", "install.sh", prefix

    bin.install_symlink prefix/"nim/bin/nim"
    bin.install_symlink prefix/"nim/bin/nim" => "nimrod"
  end

  test do
    (testpath/"hello.nim").write <<-EOS.undent
      echo("hello")
    EOS
    assert_equal "hello", shell_output("#{bin}/nim compile --verbosity:0 --run #{testpath}/hello.nim").chomp
  end
end
