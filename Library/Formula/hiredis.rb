class Hiredis < Formula
  desc "Minimalistic client for Redis"
  homepage "https://github.com/redis/hiredis"
  url "https://github.com/redis/hiredis/archive/v0.13.3.tar.gz"
  sha256 "717e6fc8dc2819bef522deaca516de9e51b9dfa68fe393b7db5c3b6079196f78"

  head "https://github.com/redis/hiredis.git"


  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = "-arch #{MacOS.preferred_arch}"

    system "make", "install", "PREFIX=#{prefix}"
    pkgshare.install "examples"
  end

  test do
    # running `./test` requires a database to connect to, so just make
    # sure it compiles
    system ENV.cc, "-I#{include}/hiredis", "-L#{lib}", "-lhiredis",
           pkgshare/"examples/example.c", "-o", testpath/"test"
    File.exist? testpath/"test"
  end
end
