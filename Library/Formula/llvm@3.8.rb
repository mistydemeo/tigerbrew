class LlvmAT38 < Formula
  desc "Next-gen compiler infrastructure"
  homepage "https://llvm.org/"

  url "https://llvm.org/releases/3.8.1/llvm-3.8.1.src.tar.xz"
  sha256 "6e82ce4adb54ff3afc18053d6981b6aed1406751b8742582ed50f04b5ab475f9"

  resource "clang" do
    url "https://llvm.org/releases/3.8.1/cfe-3.8.1.src.tar.xz"
    sha256 "4cd3836dfb4b88b597e075341cae86d61c63ce3963e45c7fe6a8bf59bb382cdf"
  end

  resource "clang-tools-extra" do
    url "https://llvm.org/releases/3.8.1/clang-tools-extra-3.8.1.src.tar.xz"
    sha256 "664a5c60220de9c290bf2a5b03d902ab731a4f95fe73a00856175ead494ec396"
  end

  resource "compiler-rt" do
    url "https://llvm.org/releases/3.8.1/compiler-rt-3.8.1.src.tar.xz"
    sha256 "0df011dae14d8700499dfc961602ee0a9572fef926202ade5dcdfe7858411e5c"
  end

  resource "polly" do
    url "https://llvm.org/releases/3.8.1/polly-3.8.1.src.tar.xz"
    sha256 "453c27e1581614bb3b6351bf5a2da2939563ea9d1de99c420f85ca8d87b928a2"
  end

  resource "lld" do
    url "https://llvm.org/releases/3.8.1/lld-3.8.1.src.tar.xz"
    sha256 "2bd9be8bb18d82f7f59e31ea33b4e58387dbdef0bc11d5c9fcd5ce9a4b16dc00"
  end

  resource "openmp" do
    url "https://llvm.org/releases/3.8.1/openmp-3.8.1.src.tar.xz"
    sha256 "68fcde6ef34e0275884a2de3450a31e931caf1d6fda8606ef14f89c4123617dc"
  end

  resource "libcxx" do
    url "https://llvm.org/releases/3.8.1/libcxx-3.8.1.src.tar.xz"
    sha256 "77d7f3784c88096d785bd705fa1bab7031ce184cd91ba8a7008abf55264eeecc"
  end

  resource "compilerrt_cmakelists" do
    url "https://trac.macports.org/raw-attachment/ticket/54242/proj-compilerrt-lib-builtins-%20alternate%20incomplete%20CMakeLists.txt"
    sha256 "c227abe2ab6836ff2de733567a4590df0c87ce0bba3d4e00c43fcf79745b6793"
  end

  if MacOS.version <= :snow_leopard
    resource "libcxxabi" do
      url "https://llvm.org/releases/3.8.1/libcxxabi-3.8.1.src.tar.xz"
      sha256 "e1b55f7be3fad746bdd3025f43e42d429fb6194aac5919c2be17c4a06314dae1"
    end
  end

  bottle do
    rebuild 1
    sha256 "f84012d316cc335ebd93e4ac6fad1548eef54da23a8c690da5d517f1c78d72fb" => :sierra
    sha256 "889759dd33dcfccb62c9ddc89541e201afbd88572d165dc0bdf5d945e681d670" => :el_capitan
    sha256 "e49da061ea21b5490c916a224f4d7c5ec85e9e982bc0e377817cad3296b4e27e" => :yosemite
  end

  patch :DATA

  # Giant batch of patches that fix builds on 10.4 and 10.5
  if MacOS.version < :snow_leopard
    resource "4000-patch-clang-lib-codegen-targetinfo-ppc-38.diff" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/4000-patch-clang-lib-codegen-targetinfo-ppc-38.diff"
      sha256 "3ec44ba60d21611c54a49bb521a0e59ab3d77d728d806f4e5e28d3db0545e139"
    end

    resource "4001-patch-clang-3.8-gccabi-sema.diff" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/4001-patch-clang-3.8-gccabi-sema.diff"
      sha256 "6d577bff4afce6d7978d17ae719a73717933e31da9f29a15ef4e46fd32cb630c"
    end

    resource "4001-patch-llvm-Only-call-setpriority-PRIO_DARWIN_THREAD-0-PRIO_DARW.diff" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/4001-patch-llvm-Only-call-setpriority-PRIO_DARWIN_THREAD-0-PRIO_DARW.diff"
      sha256 "fd0ba715ed4914e88a947cff440845ee429f6486d44e1cbe485d8d1d475beda2"
    end

    resource "4002-patch-clang-3.8-gccabi-mangler.diff" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/4002-patch-clang-3.8-gccabi-mangler.diff"
      sha256 "38dc8f2e12bd925dee2235f309068de5c60360d246071d72fbfbcb14981256f4"
    end

    resource "999-patch-clang-3.8-Toolchains-default-always-libcxx.diff" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/999-patch-clang-3.8-Toolchains-default-always-libcxx.diff"
      sha256 "edba75fe8cd12ca80426e98bae8a140a923848fd791ef2c41173db4d1b18d25e"
    end

    resource "0001-Set-the-Mach-O-CPU-Subtype-to-ppc7400-when-targeting.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0001-Set-the-Mach-O-CPU-Subtype-to-ppc7400-when-targeting.patch"
      sha256 "2419fa4c03d8b2b6adad520e559cf461d39c21c60b0d4ea6b7af00ff2046908b"
    end

    resource "0002-Define-EXC_MASK_CRASH-and-MACH_EXCEPTION_CODES-if-th.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0002-Define-EXC_MASK_CRASH-and-MACH_EXCEPTION_CODES-if-th.patch"
      sha256 "45eedac790efdbbffcac270c7ab2458333937005b7b76af3d15e5277256412d2"
    end

    resource "0003-MacPorts-Only-Update-install-targets-for-clang-subpo.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0003-MacPorts-Only-Update-install-targets-for-clang-subpo.patch"
      sha256 "74409cd8842be758d8ee6cb71a07b23a1b050c33aa715c1f2b6eacecdde9f79c"
    end

    resource "0004-MacPorts-Only-Use-full-path-for-the-dylib-id-instead.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0004-MacPorts-Only-Use-full-path-for-the-dylib-id-instead.patch"
      sha256 "68595e9e850a55b64485f85aa758654c71024897fb4c7671b0aaf38f0fc1cd22"
    end

    resource "0005-MacPorts-Only-Don-t-embed-the-deployment-target-in-t.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0005-MacPorts-Only-Don-t-embed-the-deployment-target-in-t.patch"
      sha256 "76cfa2fceb6a31430629f49e4c17e377970d37cc3a9fa49aba6c620bfb406276"
    end

    resource "0006-MacPorts-Only-Skip-checking-for-python-in-configure.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0006-MacPorts-Only-Skip-checking-for-python-in-configure.patch"
      sha256 "e77899c8e30615dd0530db915eae491375008dc8ab41effabaf85a5c761537e1"
    end

    resource "0007-Remove-override-of-raise-abort-and-__assert_rtn.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0007-Remove-override-of-raise-abort-and-__assert_rtn.patch"
      sha256 "c4798a35c187ddab3daed3316e87c63e54e02561dc33d861f55ee4fcca4e0737"
    end

    resource "0008-CMake-Use-CMake-s-default-RPATH-for-the-unit-tests.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0008-CMake-Use-CMake-s-default-RPATH-for-the-unit-tests.patch"
      sha256 "281ac3a1413eb2f9b8a81d15750606f2fbd37175aa1b8f2fa81fe7dfcf3481b7"
    end

    resource "0009-CMake-Fix-rpath-construction-for-out-of-tree-builds.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0009-CMake-Fix-rpath-construction-for-out-of-tree-builds.patch"
      sha256 "9b419798df9eb14956f8b11ed69cce51633c0886a4810fb43fb46e68ac89a72a"
    end

    resource "0010-CMake-Make-CMAKE_INSTALL_RPATH-work-again.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0010-CMake-Make-CMAKE_INSTALL_RPATH-work-again.patch"
      sha256 "e3907117f8bca7c5917bd53d3c064d25d526d521afed042629cdd344d3edc811"
    end

    resource "0011-CMake-Fix-llvm_setup_rpath-function.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/0011-CMake-Fix-llvm_setup_rpath-function.patch"
      sha256 "4b5e53c07611bb3c3ad9f501d92651617006d128c554ef461dc611c0a7473f82"
    end

    resource "1001-MacPorts-Only-Prepare-clang-format-for-replacement-w.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1001-MacPorts-Only-Prepare-clang-format-for-replacement-w.patch"
      sha256 "36ae75541f4a37bc1da59768d85f6710d5801d4d4122ede2823089435ff8678d"
    end

    resource "1002-MacPorts-Only-Fall-back-on-xcodebuild-sdk-when-xcrun.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1002-MacPorts-Only-Fall-back-on-xcodebuild-sdk-when-xcrun.patch"
      sha256 "d6fa1f75f239ba6e290cb5eccbf1a26f403a3831d056b29c9f17b84ffca30e68"
    end

    resource "1003-MacPorts-Only-Fix-name-of-scan-view-executable-insid.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1003-MacPorts-Only-Fix-name-of-scan-view-executable-insid.patch"
      sha256 "e5ea01023665cfdff884403d1c4fbde3219aed51fe0712c7935d1b39728f11ca"
    end

    resource "1004-MacPorts-Only-Relocate-clang-resources-using-llvm-ve.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1004-MacPorts-Only-Relocate-clang-resources-using-llvm-ve.patch"
      sha256 "9123a490e25f1ff0ac84496180d3f287d247b9ab45dc6ce4adc92c300311eba9"
    end

    resource "1005-Default-to-ppc7400-for-OSX-10.5.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1005-Default-to-ppc7400-for-OSX-10.5.patch"
      sha256 "b1d6bc9bed47a15d2e9aa9010a3dcdbcc55ca86e52f7fbe633259fe6773c891b"
    end

    resource "1006-Only-call-setpriority-PRIO_DARWIN_THREAD-0-PRIO_DARW.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1006-Only-call-setpriority-PRIO_DARWIN_THREAD-0-PRIO_DARW.patch"
      sha256 "e0575b6015a56992f10ea4bf10419fc7495cb1591d7214329fdf286048ba0ca4"
    end

    resource "1007-Default-to-fragile-ObjC-runtime-when-targeting-darwi.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1007-Default-to-fragile-ObjC-runtime-when-targeting-darwi.patch"
      sha256 "637dd035174e5ce5871f08d004efbd80a32a34dfd39d1ba9c0a2b8c2eee0957f"
    end

    resource "1008-Fixup-libstdc-header-search-paths-for-older-versions.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1008-Fixup-libstdc-header-search-paths-for-older-versions.patch"
      sha256 "a51d4633dc88ab5adbbeb705e60f9c55dbabb3b9e26b40268aab22686fcfb70f"
    end

    resource "1009-Darwin-Stop-linking-libclang_rt.eprintf.a.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/1009-Darwin-Stop-linking-libclang_rt.eprintf.a.patch"
      sha256 "3663d5e4e16447f4438cf02dd4eba5473dd10fa93759e38ea7a7eb239b6c0882"
    end

    resource "2001-MacPorts-Only-Comment-out-SL-cctools-workaround.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2001-MacPorts-Only-Comment-out-SL-cctools-workaround.patch"
      sha256 "09de02d6acba21e51a34f95be19ff3030bdda9e7921e884159217bc2434699df"
    end

    resource "2002-Update-CheckArches-to-fallback-on-Intel-ppc-if-ld-v-.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2002-Update-CheckArches-to-fallback-on-Intel-ppc-if-ld-v-.patch"
      sha256 "1bdf6a86e767ab66467aac2b79c49879a5e8325eba98d26faa1803546e582a96"
    end

    resource "2003-Fall-back-on-xcodebuild-sdk-when-xcrun-sdk-is-not-su.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2003-Fall-back-on-xcodebuild-sdk-when-xcrun-sdk-is-not-su.patch"
      sha256 "e2c98df8a0afc7710ce077094e05eb9a8c2bc04fcd1b9333eb179c73448ac98a"
    end

    resource "2004-On-darwin-build-ppc-slices-of-the-compiler-runtime-i.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2004-On-darwin-build-ppc-slices-of-the-compiler-runtime-i.patch"
      sha256 "5ee665321f4f62bef6aa484c71f1204836b790007d0392f19d1fd95a18c0b632"
    end

    resource "2005-MacPorts-Only-Don-t-build-x86_64h-slice-of-compiler-.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2005-MacPorts-Only-Don-t-build-x86_64h-slice-of-compiler-.patch"
      sha256 "187323919a85479fa6aaee323169456a05a9ab39e83219efa1d440481858c47c"
    end

    resource "2006-MacPorts-Only-Fix-regression-introduced-when-fixing-.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2006-MacPorts-Only-Fix-regression-introduced-when-fixing-.patch"
      sha256 "669cf7dd9eefa8a2c00ec890f4b3be6de51f64661fbb4452f518223b42676285"
    end

    resource "2007-MacPorts-Only-Don-t-check-for-the-macosx.internal-SD.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2007-MacPorts-Only-Don-t-check-for-the-macosx.internal-SD.patch"
      sha256 "9ea9586bc82d7ef5428c5435504f132bb009876f9accd9ba3b2065ed7862c2b7"
    end

    resource "2008-CMake-NFC-Move-macro-definitions-out-of-config-ix.cm.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2008-CMake-NFC-Move-macro-definitions-out-of-config-ix.cm.patch"
      sha256 "9577ccce75140887e7e3f7ac203414ceb1d8bb8956e0ad88e9294b19c386cbda"
    end

    resource "2009-CMake-Adding-some-missing-CMake-includes.-NFC.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2009-CMake-Adding-some-missing-CMake-includes.-NFC.patch"
      sha256 "f7f4b2a1654464ca52336e3852e17f0d130a7f804b08e8692c5de4fc1d4ed192"
    end

    resource "2010-CMake-Adding-another-missing-include.-NFC.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2010-CMake-Adding-another-missing-include.-NFC.patch"
      sha256 "0cfb1d89bcd4c2a54cccf2350c34ddd5eeda1aa376b7d377187f9c2f2fb782b2"
    end

    resource "2011-CMake-NFC.-Add-support-for-testing-the-compiler-with.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2011-CMake-NFC.-Add-support-for-testing-the-compiler-with.patch"
      sha256 "9bab589b168d1b5e428ff41f1ae2cc7d44b22c9fe25c73ad9b0b75e45055cf2b"
    end

    resource "2012-Add-missing-include.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/2012-Add-missing-include.patch"
      sha256 "792e09f615e3873854f3071d8a2deb3a9b3717664be62bcb110285cec4c66479"
    end

    resource "3001-buildit-build-fix-for-Leopard.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/3001-buildit-build-fix-for-Leopard.patch"
      sha256 "f2e8ed5a18c9995182584c2b904f92eff67efb62a88d7bc8ea31738fac6ad2d8"
    end

    resource "3002-buildit-Set-compatibility-version-to-RC_ProjectSourc.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/3002-buildit-Set-compatibility-version-to-RC_ProjectSourc.patch"
      sha256 "c7fda46fac6f164d39b5d5a364c533f890a4d3d3035585e8f44d13765609531f"
    end

    resource "3003-Fix-local-and-iterator-when-building-with-Lion-and-n.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/3003-Fix-local-and-iterator-when-building-with-Lion-and-n.patch"
      sha256 "9d2ff1cb46c504eccd6656a4495b518ea5942a254c4f2bfa8a64f0e72b8c1148"
    end

    resource "3004-Fix-missing-long-long-math-prototypes-when-using-the.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/3004-Fix-missing-long-long-math-prototypes-when-using-the.patch"
      sha256 "4e5b21353303ce3ca4ce718c68bc017e84f6c5177d732c04b95da496ca0f214d"
    end

    resource "3005-implement-atomic-using-mutex-lock_guard-for-64b-ops-.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/3005-implement-atomic-using-mutex-lock_guard-for-64b-ops-.patch"
      sha256 "136a400af5ff3d686ee95dd156c01cde7c678f04b132414c12c9d8b7adff2c39"
    end

    resource "compiler_rt-toolchain.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/compiler_rt-toolchain.patch"
      sha256 "5ddabde13f5563171eec96b530e606a4a3193a1546ae7f25aafb6998f426d92b"
    end

    resource "leopard-no-asan.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/leopard-no-asan.patch"
      sha256 "72ff067d3d30ec3f7e86221d40f2e0b39b36ed70c7815b7e1b9729b85e4dc64b"
    end

    resource "leopard-no-blocks.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/leopard-no-blocks.patch"
      sha256 "1bc301ad8180be3b5ef8fca513e6f3534112d531bb8cfd6282a583cf438afe0f"
    end

    resource "llvm-skip-unittests.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/llvm-skip-unittests.patch"
      sha256 "2ba50b6256d5630ffcb6aaf3a8611f6c77e5653a951f3e595beb3bc9d85ca5c3"
    end

    resource "openmp-locations.patch" do
      url "https://github.com/kencu/LeopardPorts/raw/0a0fcace43631235c274410d5664c053cb462ea9/lang/llvm-3.8/files/openmp-locations.patch"
      sha256 "ed079cf0a66ba6d60b96115b22b9418d1e27839c07719771b4ecd3e04979dbb3"
    end
  end

  if MacOS.version < :snow_leopard
    depends_on "cctools" => :build
    depends_on "python" => :build
  end

  depends_on "gnu-sed" => :build
  depends_on "gmp"
  depends_on "libffi"

  # version suffix
  def ver
    "3.8"
  end

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc

  def install
    # One of llvm makefiles relies on gnu sed behavior to generate CMake modules correctly
    ENV.prepend_path "PATH", "#{Formula["gnu-sed"].opt_libexec}/gnubin"
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    clang_buildpath = buildpath/"tools/clang"
    compilerrt_buildpath = buildpath/"tools/compiler-rt"
    libcxx_buildpath = buildpath/"projects/libcxx"
    libcxxabi_buildpath = buildpath/"libcxxabi" # build failure if put in projects due to no Makefile

    clang_buildpath.install resource("clang")
    compilerrt_buildpath.install resource("compiler-rt")
    compilerrt_buildpath.install resource("compilerrt_cmakelists")
    libcxx_buildpath.install resource("libcxx")
    (buildpath/"tools/polly").install resource("polly")
    (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    (buildpath/"projects/openmp").install resource("openmp")

    # HUGE HACK
    # These patches cover several subprojects, so they can't use Homebrew's normal
    # patching mechanism.
    resources.select { |r| r.url.end_with?(".diff") || r.url.end_with?(".patch") }.each do |res|
      buildpath.install res
      filename = res.name
      system "patch", "-p1", "-i", filename
      rm filename
    end

    ENV["REQUIRES_RTTI"] = "1"

    install_prefix = lib/"llvm-#{ver}"

    args = %W[
      --prefix=#{install_prefix}
      --enable-optimized
      --disable-bindings
      --with-gmp=#{Formula["gmp"].opt_prefix}
      --enable-shared
      --enable-targets=all
      --enable-libffi
    ]

    if Hardware::CPU.type == :ppc
      args << "--with-clang-default-openmp-runtime=libgomp"
    end

    mktemp do
      system buildpath/"configure", *args
      system "make", "VERBOSE=1", "install"
      cd "tools/clang" do
        system "make", "install"
      end
    end

    if MacOS.version <= :snow_leopard
      libcxxabi_buildpath.install resource("libcxxabi")

      cd libcxxabi_buildpath/"lib" do
        # Set rpath to save user from setting DYLD_LIBRARY_PATH
        inreplace "buildit", "-install_name /usr/lib/libc++abi.dylib", "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

        ENV["CC"] = "#{install_prefix}/bin/clang"
        ENV["CXX"] = "#{install_prefix}/bin/clang++"
        ENV["TRIPLE"] = "*-apple-*"
        system "./buildit"
        (install_prefix/"usr/lib").install "libc++abi.dylib"
        cp libcxxabi_buildpath/"include/cxxabi.h", install_prefix/"lib/c++/v1"
      end

      # Snow Leopard make rules hardcode libc++ and libc++abi path.
      # Change to Cellar path here.
      inreplace "#{libcxx_buildpath}/lib/buildit" do |s|
        s.gsub! "-install_name /usr/lib/libc++.1.dylib", "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        s.gsub! "-Wl,-reexport_library,/usr/lib/libc++abi.dylib", "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/"include/cxxabi.h", libcxx_buildpath/"include"
    end

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    libcxx_make_args = [
      # Use the built clang for building
      "CC=#{install_prefix}/bin/clang",
      "CXX=#{install_prefix}/bin/clang++",
      # Properly set deployment target, which is needed for Snow Leopard
      "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
      # The following flags are needed so it can be installed correctly.
      "DSTROOT=#{install_prefix}",
      "SYMROOT=#{libcxx_buildpath}",
    ]

    system "make", "-C", libcxx_buildpath, "install", *libcxx_make_args

    (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
    inreplace share/"clang/tools/scan-build/bin/scan-build", "$RealBin/bin/clang", bin/"clang-#{ver}"
    bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
    man1.install_symlink share/"clang/tools/scan-build/man/scan-build.1"

    (lib/"python2.7/site-packages").install "bindings/python/llvm" => "llvm-#{ver}",
                                            clang_buildpath/"bindings/python/clang" => "clang-#{ver}"

    Dir.glob(install_prefix/"bin/*") do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    Dir.glob(install_prefix/"share/man/man1/*") do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  def caveats; <<-EOS.undent
    Extra tools are installed in #{opt_share}/clang-#{ver}

    To link to libc++, something like the following is required:
      CXX="clang++-#{ver} -stdlib=libc++"
      CXXFLAGS="$CXXFLAGS -nostdinc++ -I#{opt_lib}/llvm-#{ver}/include/c++/v1"
      LDFLAGS="$LDFLAGS -L#{opt_lib}/llvm-#{ver}/lib"
    EOS
  end

  test do
    # test for sed errors since some llvm makefiles assume that sed
    # understands '\n' which is true for gnu sed and not for bsd sed.
    assert_no_match /PATH\)n/, (lib/"llvm-3.8/share/llvm/cmake/LLVMConfig.cmake").read
    system "#{bin}/llvm-config-#{ver}", "--version"
  end
end

__END__
diff --git a/Makefile.rules b/Makefile.rules
index ebebc0a..b0bb378 100644
--- a/Makefile.rules
+++ b/Makefile.rules
@@ -600,7 +600,12 @@ ifneq ($(HOST_OS), $(filter $(HOST_OS), Cygwin MingW))
 ifneq ($(HOST_OS),Darwin)
   LD.Flags += $(RPATH) -Wl,'$$ORIGIN'
 else
-  LD.Flags += -Wl,-install_name  -Wl,"@rpath/lib$(LIBRARYNAME)$(SHLIBEXT)"
+  LD.Flags += -Wl,-install_name
+  ifdef LOADABLE_MODULE
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(LIBRARYNAME)$(SHLIBEXT)"
+  else
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(SharedPrefix)$(LIBRARYNAME)$(SHLIBEXT)"
+  endif
 endif
 endif
 endif
diff --git a/configure b/configure
index c94fb13..8d61650 100755
--- a/configure
+++ b/configure
@@ -1,6 +1,6 @@
 #! /bin/sh
 # Guess values for system-dependent variables and create Makefiles.
-# Generated by GNU Autoconf 2.60 for LLVM 3.8.0.
+# Generated by GNU Autoconf 2.60 for LLVM 3.8.1.
 #
 # Report bugs to <http://llvm.org/bugs/>.
 #
@@ -561,8 +561,8 @@ SHELL=${CONFIG_SHELL-/bin/sh}
 # Identity of this package.
 PACKAGE_NAME='LLVM'
 PACKAGE_TARNAME='llvm'
-PACKAGE_VERSION='3.8.0'
-PACKAGE_STRING='LLVM 3.8.0'
+PACKAGE_VERSION='3.8.1'
+PACKAGE_STRING='LLVM 3.8.1'
 PACKAGE_BUGREPORT='http://llvm.org/bugs/'

 ac_unique_file="lib/IR/Module.cpp"
@@ -1334,7 +1334,7 @@ if test "$ac_init_help" = "long"; then
   # Omit some internal or obsolete options to make the list less imposing.
   # This message is too long to be a string in the A/UX 3.1 sh.
   cat <<_ACEOF
-\`configure' configures LLVM 3.8.0 to adapt to many kinds of systems.
+\`configure' configures LLVM 3.8.1 to adapt to many kinds of systems.

 Usage: $0 [OPTION]... [VAR=VALUE]...

@@ -1400,7 +1400,7 @@ fi

 if test -n "$ac_init_help"; then
   case $ac_init_help in
-     short | recursive ) echo "Configuration of LLVM 3.8.0:";;
+     short | recursive ) echo "Configuration of LLVM 3.8.1:";;
    esac
   cat <<\_ACEOF

@@ -1584,7 +1584,7 @@ fi
 test -n "$ac_init_help" && exit $ac_status
 if $ac_init_version; then
   cat <<\_ACEOF
-LLVM configure 3.8.0
+LLVM configure 3.8.1
 generated by GNU Autoconf 2.60

 Copyright (C) 1992, 1993, 1994, 1995, 1996, 1998, 1999, 2000, 2001,
@@ -1600,7 +1600,7 @@ cat >config.log <<_ACEOF
 This file contains any messages produced by compilers while
 running configure, to aid debugging if configure makes a mistake.

-It was created by LLVM $as_me 3.8.0, which was
+It was created by LLVM $as_me 3.8.1, which was
 generated by GNU Autoconf 2.60.  Invocation command line was

   $ $0 $@
@@ -1956,7 +1956,7 @@ ac_compiler_gnu=$ac_cv_c_compiler_gnu

 LLVM_VERSION_MAJOR=3
 LLVM_VERSION_MINOR=8
-LLVM_VERSION_PATCH=0
+LLVM_VERSION_PATCH=1
 LLVM_VERSION_SUFFIX=


@@ -18279,7 +18279,7 @@ exec 6>&1
 # report actual input values of CONFIG_FILES etc. instead of their
 # values after options handling.
 ac_log="
-This file was extended by LLVM $as_me 3.8.0, which was
+This file was extended by LLVM $as_me 3.8.1, which was
 generated by GNU Autoconf 2.60.  Invocation command line was

   CONFIG_FILES    = $CONFIG_FILES
@@ -18332,7 +18332,7 @@ Report bugs to <bug-autoconf@gnu.org>."
 _ACEOF
 cat >>$CONFIG_STATUS <<_ACEOF
 ac_cs_version="\\
-LLVM config.status 3.8.0
+LLVM config.status 3.8.1
 configured by $0, generated by GNU Autoconf 2.60,
   with options \\"`echo "$ac_configure_args" | sed 's/^ //; s/[\\""\`\$]/\\\\&/g'`\\"
