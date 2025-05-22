class Ponysay < Formula
  desc "Cowsay but with ponies"
  homepage "http://erkin.co/ponysay/"
  url "https://github.com/erkin/ponysay/archive/3.0.2.tar.gz"
  sha256 "69e98a7966353de2f232cbdaccd8ef7dbc5d0bcede9bf7280a676793e8625b0d"
  revision 1


  depends_on :python3
  depends_on "coreutils"

  # fix shell completion install paths
  # https://github.com/erkin/ponysay/pull/225
  patch do
    url "https://github.com/tdsmith/ponysay/commit/44fb0f85821eb34a811abb27d2c601a5d30af1f1.diff"
    sha256 "0570b94a1179c189291cd9bad28cb93762aeed5ad6bbc3536027e178d0e6b9df"
  end

  def install
    system "./setup.py",
           "--freedom=partial",
           "--prefix=#{prefix}",
           "--cache-dir=#{prefix}/var/cache",
           "--sysconf-dir=#{prefix}/etc",
           "install"
  end

  test do
    system "#{bin}/ponysay", "-A"
  end
end
