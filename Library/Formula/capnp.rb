class Capnp < Formula
  desc "Data interchange format and capability-based RPC system"
  homepage "https://capnproto.org/"
  url "https://capnproto.org/capnproto-c++-0.5.3.tar.gz"
  sha256 "cdb17c792493bdcd4a24bcd196eb09f70ee64c83a3eccb0bc6534ff560536afb"


  needs :cxx11
  depends_on "cmake" => :build

  def install
    ENV.cxx11

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "check"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/capnp", "--version"
  end
end
