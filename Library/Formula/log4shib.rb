class Log4shib < Formula
  desc "Forked version of log4cpp for the Shibboleth project"
  homepage "https://wiki.shibboleth.net/confluence/display/OpenSAML/log4shib"
  url "http://shibboleth.net/downloads/log4shib/1.0.9/log4shib-1.0.9.tar.gz"
  sha256 "b34cc90f50962cc245a238b472f72852732d32a9caf9a10e0244d0e70a311d6d"


  def install
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    assert_equal "-L#{HOMEBREW_PREFIX}/Cellar/log4shib/1.0.9/lib -llog4shib",
                 shell_output("#{bin}/log4shib-config --libs").chomp
  end
end
