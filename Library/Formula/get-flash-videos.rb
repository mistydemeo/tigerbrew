class GetFlashVideos < Formula
  desc "Download or play videos from various Flash-based websites"
  homepage "https://github.com/monsieurvideo/get-flash-videos"
  url "https://web.archive.org/web/20160113214146/https://get-flash-videos.googlecode.com/files/combined-get_flash_videos-1.24"
  version "1.24"
  sha256 "e41da715f817bfa1a65ae82cc4f5a82268b6e72a7f4d90ffabf89b3a522cbb91"

  def install
    bin.install "combined-get_flash_videos-1.24" => "get_flash_videos"
  end

  test do
    system "get_flash_videos", "http://gawker.com/indiana-pizzeria-takes-brave-stand-of-denying-gays-pizz-1694992744#"
    rm "Indiana_Pizzeria_Takes_Brave_Stand_of_Denying_Gays_Pizza_for_Weddings.flv"
  end
end
