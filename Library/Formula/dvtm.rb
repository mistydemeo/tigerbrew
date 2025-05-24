class Dvtm < Formula
  desc "Dynamic Virtual Terminal Manager"
  homepage "http://www.brain-dump.org/projects/dvtm/"
  url "http://www.brain-dump.org/projects/dvtm/dvtm-0.14.tar.gz"
  sha256 "8a9bb341f8a4c578b839e22d9a707f053a27ae6df15158e16f4fee787e43747a"
  head "git://repo.or.cz/dvtm.git"


  def install
    ENV.append_to_cflags "-D_DARWIN_C_SOURCE"
    system "make", "PREFIX=#{prefix}", "LIBS=-lc -lutil -lncurses", "install"
  end

  test do
    result = shell_output("#{bin}/dvtm -v")
    result.force_encoding("UTF-8") if result.respond_to?(:force_encoding)
    assert_match /^dvtm-#{version}/, result
  end
end
