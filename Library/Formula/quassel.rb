class Quassel < Formula
  desc "Distributed IRC client (Qt-based)"
  homepage "http://www.quassel-irc.org/"
  head "https://github.com/quassel/quassel.git"

  stable do
    url "http://www.quassel-irc.org/pub/quassel-0.11.0.tar.bz2"
    sha256 "99a191b8bc2a410f7020b890ec57e0be49313f539da9f4843675bb108b0f4504"

    # http://www.openwall.com/lists/oss-security/2015/03/20/12
    patch do
      url "https://github.com/quassel/quassel/commit/b5e38970ffd55.diff"
      sha256 "324ce0edfe5744544846a4796187ceda77921434498089c49c2e50a7f8654fa1"
    end
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  # Official binary packages upstream now built against qt5 by default. But source
  # packages default to qt4 *for now*, and Homebrew prioritises qt5 in PATH due to keg_only.
  depends_on "qt5" => :optional
  depends_on "qt" => :recommended

  needs :cxx11

  def install
    ENV.cxx11

    args = std_cmake_args
    args << "."
    args << "-DUSE_QT5=ON" if build.with? "qt5"

    system "cmake", *args
    system "make", "install"
  end

  test do
    assert_match /Quassel IRC/, shell_output("#{bin}/quasselcore -v", 1)
  end
end
