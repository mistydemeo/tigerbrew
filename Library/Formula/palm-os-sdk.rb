class PalmOsSdk < Formula
  desc "Collection of Palm OS SDKs"
  homepage "https://web.archive.org/web/20041204085429/http://www.palmos.com:80/dev/tools/core.html"
  url "https://github.com/jichu4n/palm-os-sdk/archive/1fa22066ca0f8b74949c14dd1d626294145d1c09.tar.gz"
  version "2023-12-19"
  sha256 "f4481184a489929aac44395f933b53af75d684a1c26ce217deb61566be80be53"

  depends_on "prc-tools"

  def install
    cp_r Dir["*"], "#{prefix}"
    mkdir_p "#{Formula["prc-tools"].opt_prefix}/palm-os-sdks"
    ["sdk-1", "sdk-2", "sdk-3.1", "sdk-3.5", "sdk-4", "sdk-5r3", "sdk-5r4"].each do |sdks|
      ln_s "#{prefix}/#{sdks}", "#{Formula["prc-tools"].opt_prefix}/palm-os-sdks/#{sdks}"
    end
    # palmdev-prep looks for directories prefixed with "sdk-".
    # State the version number first in the target symlink to help sort so that sdk-5r4 remains default.
    ln_s "#{prefix}/dana-2.0", "#{Formula["prc-tools"].opt_prefix}/palm-os-sdks/sdk-2.0-dana"
    ln_s "#{prefix}/handera-105", "#{Formula["prc-tools"].opt_prefix}/palm-os-sdks/sdk-1.05-handera"

    system "#{Formula["prc-tools"].opt_bin}/palmdev-prep"
  end

  def caveats; <<~EOS
    When GCC is given no -palmos options, SDK '5r4' will be used by default.
    Run #{HOMEBREW_PREFIX}/bin/palmdev-prep to change the default SDK.
    EOS
  end
end
