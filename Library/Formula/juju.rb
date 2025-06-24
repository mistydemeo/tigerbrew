class Juju < Formula
  desc "DevOps management tool"
  homepage "https://juju.ubuntu.com"
  url "https://launchpad.net/juju-core/1.24/1.24.6/+download/juju-core_1.24.6.tar.gz"
  sha256 "00928687041e3520146d7d937a51d1e7caf9b588bb9c80f02846addebe452cbd"


  depends_on "go" => :build

  # El Capitan is not registered in Juju 1.24.x.
  # https://bugs.launchpad.net/juju-core/+bug/1465317
  # https://github.com/juju/juju/pull/3388
  patch do
    url "https://gist.githubusercontent.com/sinzui/68da12cb48493d41bdbc/raw/29f30ce225be0c4599ef2834f1585c939a507348/el-capitan.patch"
    sha256 "326764b4c6da32823aa70b4a5f03a1d196983de4714a8d259e44e7a7a1ac53fe"
  end

  def install
    ENV["GOPATH"] = buildpath
    system "go", "build", "github.com/juju/juju/cmd/juju"
    system "go", "build", "github.com/juju/juju/cmd/plugins/juju-metadata"
    bin.install "juju", "juju-metadata"
    bash_completion.install "src/github.com/juju/juju/etc/bash_completion.d/juju-core"
  end

  test do
    system "#{bin}/juju", "version"
  end
end
