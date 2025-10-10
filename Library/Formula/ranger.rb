class Ranger < Formula
  desc "File browser"
  homepage "https://ranger.github.io"
  url "https://ranger.github.io/ranger-1.9.4.tar.gz"
  sha256 "7ad75e0d1b29087335fbb1691b05a800f777f4ec9cba84faa19355075d7f0f89"
  license "GPL-3.0-or-later"
  head "https://github.com/ranger/ranger.git", branch: "master"

  depends_on :python3

  option "with-libcaca", "For ASCII-art image previews"
  depends_on "libcaca" => :optional

  option "with-imagemagick", "To auto-rotate images and for image previews"
  depends_on "imagemagick" => :optional

  option "with-librsvg", "For SVG previews"
  depends_on "librsvg" => :optional

  option "with-ffmpeg", "For video thumbnails"
  depends_on "ffmpeg" => :optional
  option "with-ffmpegthumbnailer", "For video thumbnails"
  depends_on "ffmpegthumbnailer" => :optional

  option "with-highlight", "For syntax highlighting of code"
  depends_on "highlight" => :optional

  option "with-atool", "To preview archives"
  depends_on "atool" => :optional
  option "with-unrar", "To preview archives"
  depends_on "unrar" => :optional
  option "with-p7zip", "To preview archives"
  depends_on "p7zip" => :optional

  option "with-lynx", "To preview HTML pages"
  depends_on "lynx" => :optional
  option "with-w3m", "To preview HTML pages"
  depends_on "w3m" => :optional
  option "with-elinks", "To preview HTML pages"
  depends_on "elinks" => :optional

  option "with-poppler", "For textual PDF previews"
  depends_on "poppler" => :optional
  option "with-mupdf-tools", "For textual PDF previews"
  depends_on "mupdf-tools" => :optional

  option "with-transmission", "For viewing BitTorrent information"
  depends_on "transmission" => :optional

  option "with-media-info", "For viewing information about media files"
  depends_on "media-info" => :optional
  option "with-exiftool", "For viewing information about media files"
  depends_on "exiftool" => :optional

  option "with-odt2txt", "For OpenDocument text files"
  depends_on "odt2txt" => :optional

  option "with-jq", "For JSON files"
  depends_on "jq" => :optional

  option "with-sqlite", "For listing tables in SQLite database"
  depends_on "sqlite" => :optional

  def install
    inreplace %w[ranger.py ranger/ext/rifle.py] do |s|
      s.gsub! "#!/usr/bin/python", "#!#{Formula["python3"].opt_bin}/python3"
    end

    inreplace %w[
      doc/tools/convert_papermode_to_metadata.py
      doc/tools/performance_test.py
      doc/tools/print_colors.py
      doc/tools/print_keys.py
    ] do |s|
      s.gsub! "#!/usr/bin/env python", "#!/usr/bin/env python3"
    end

    man1.install "doc/ranger.1"
    man1.install "doc/rifle.1"
    doc.install "doc/cheatsheet.svg", "doc/colorschemes.md", "doc/config", "doc/tools", "examples"
    libexec.install "ranger.py", "ranger"
    bin.install_symlink libexec/"ranger.py" => "ranger"
    bin.install_symlink libexec/"ranger/ext/rifle.py" => "rifle"
  end

  test do
    assert_match version.to_s, shell_output("script -q /dev/null #{bin}/ranger --version")
    assert_match version.to_s, shell_output("script -q /dev/null #{bin}/rifle --version")
  end
end
