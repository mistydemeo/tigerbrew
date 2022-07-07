class Neofetch < Formula
    desc "A CLI system information tool written in BASH"
    homepage "https://github.com/dylanaraps/neofetch"
    url "https://github.com/dylanaraps/neofetch/archive/refs/heads/master.zip"
    sha256 "13b188b1fd5bba04bf751c94757c62630c79a553d57680dcae8dcdedd529799a"
    version "7.1.0"

    patch do
        url "https://github.com/ablakely/neofetch/commit/993cfbc62776cb6e17def9ec53751b0876312a1d.patch?full_index=1"
        sha256 "e06a76dc9adc4a9b04e8159bf036e7a7d8abd00dca64c31053fd093a5c19a4bd"
    end

    patch do
        url "https://github.com/ablakely/neofetch/commit/55483a179d2005119ac68c4565014a1bb31ac2c5.patch?full_index=1"
        sha256 "f0e376abc1af08f9137660fe9fe81767d2920168476d875e9f1c1c71849bbf3c"
    end

    def install
        system "make", "install"
    end
end
