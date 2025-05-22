class Lastfmlib < Formula
  desc "Implements Last.fm v1.2 submissions protocol for scrobbling"
  homepage "https://code.google.com/p/lastfmlib/"
  url "https://lastfmlib.googlecode.com/files/lastfmlib-0.4.0.tar.gz"
  sha256 "28ecaffe2efecd5ac6ac00ba8e0a07b08e7fb35b45dfe384d88392ad6428309a"


  depends_on "pkg-config" => :build

  fails_with :clang do
    cause <<-EOS.undent
      lastfmlib/utils/stringoperations.h:62:16: error: no viable conversion from
            '__string_type' (aka 'basic_string<wchar_t, std::char_traits<wchar_t>,
            std::allocator<wchar_t> >') to 'std::string' (aka 'basic_string<char>')
      EOS
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
