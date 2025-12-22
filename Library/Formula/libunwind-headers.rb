class LibunwindHeaders < Formula
  desc "C API for determining the call-chain of a program"
  homepage "https://github.com/apple-oss-distributions/libunwind/tree/libunwind-35.1"
  url "https://github.com/apple-oss-distributions/libunwind/archive/refs/tags/libunwind-35.1.tar.gz"
  sha256 "5b308edc7d474cc5a1506e622769cb2080bb00983ee2c4596db1f2f3c0df639b"

  bottle do
    cellar :any_skip_relocation
    sha256 "685fa240960d6f6e4691355580006a6a6a892ffc1d4f442cb26aaa8646fd2f47" => :tiger_g3
  end

  keg_only :provided_by_osx,
    "This package includes official development headers not installed by Apple."

  def install
    inreplace "include/libunwind.h", "__MAC_10_6", "__MAC_NA" if MacOS.version < :snow_leopard

    if MacOS.version < :leopard
      inreplace "include/libunwind.h", /__OSX_AVAILABLE_STARTING\(__MAC_NA,.*\)/,
        "__attribute__((unavailable))"

      inreplace %w[include/libunwind.h include/unwind.h src/AddressSpace.hpp src/InternalMacros.h],
        "Availability.h", "AvailabilityMacros.h"
    end

    include.install Dir["include/*"]
    (include/"libunwind").install Dir["src/*.h*"]
    (include/"libunwind/libunwind_priv.h").unlink
  end
end
