class Sleepwatcher < Formula
  desc "Monitors sleep, wakeup, and idleness of a Mac"
  homepage "https://www.bernhard-baehr.de/"
  # Sleepwatcher >=2.1 requires IOKit APIs which were added in Leopard
  if MacOS.version >= :leopard
    url "https://www.bernhard-baehr.de/sleepwatcher_2.2.tgz"
    sha256 "c04ac1c49e2b5785ed5d5c375854c9c0b9e959affa46adab57985e4123e8b6be"
  else
    url "https://www.bernhard-baehr.de/sleepwatcher_2.0.5_src.tgz"
    sha256 "54f1fd7a3b7345c9202eeda39f3ec3b7d6a9cfc2d02729508250220f9cc455c4"
  end

  def install
    # Version 2.0 has the Makefile in the root, later versions in a subdirectory
    dir = if MacOS.version >= :leopard
            "sources"
          else
            "."
          end

    cd dir do
      # Adjust Makefile to build native binary only
      inreplace "Makefile" do |s|
        s.gsub! /^(CFLAGS)_PPC.*$/, "\\1 = #{ENV.cflags} -prebind"
        s.gsub! /^(CFLAGS_X86)/, "#\\1"
        s.change_make_var! "BINDIR", "$(PREFIX)/sbin"
        s.change_make_var! "MANDIR", "$(PREFIX)/share/man"
        s.gsub! /^(.*?)CFLAGS_PPC(.*?)[.]ppc/, "\\1CFLAGS\\2"
        s.gsub! /^(.*?CFLAGS_X86.*?[.]x86)/, "#\\1"
        s.gsub! /^(\t(lipo|rm).*?[.](ppc|x86))/, "#\\1"
        s.gsub! "-o root -g wheel", ""
      end

      # Build and install binary
      system "mv", "../sleepwatcher.8", "." if MacOS.version >= :leopard
      system "make", "install", "PREFIX=#{prefix}"
    end

    if MacOS.version >= :leopard
      # Write the sleep/wakeup scripts
      (prefix + "etc/sleepwatcher").install Dir["config/rc.*"]

      # Write the launchd scripts
      inreplace Dir["config/*.plist"] do |s|
        s.gsub! "/usr/local/sbin", HOMEBREW_PREFIX/"sbin"
      end

      inreplace "config/de.bernhard-baehr.sleepwatcher-20compatibility.plist" do |s|
        s.gsub! "/etc", (etc + "sleepwatcher")
      end

      prefix.install Dir["config/*.plist"]
    else
      cd "SleepWatcher StartupItem.package/packagemaker.files" do
        # Remove extraneous CVS metadata
        rm_r Dir["**/CVS"]

        # Write the sleep/wakeup scripts
        (prefix + "etc/sleepwatcher").install Dir["private/etc/rc.*"]

        # Write the Startup Items
        inreplace "Library/StartupItems/SleepWatcher/SleepWatcher" do |s|
          s.gsub! "/usr/local/sbin", HOMEBREW_PREFIX/"sbin"
          s.gsub! "/etc", (etc + "sleepwatcher")
        end

        (prefix + "StartupItems").install "Library/StartupItems/SleepWatcher"
      end
    end
  end

  def caveats
    if MacOS.version >= :leopard
      <<-EOS.undent
      For SleepWatcher to work, you will need to read the following:

        #{prefix}/ReadMe.rtf

      Ignore information about installing the binary and man page,
      but read information regarding setup of the launchd files which
      are installed here:

        #{Dir["#{prefix}/*.plist"].join("\n      ")}

      These are the examples provided by the author.
      EOS
    else
      <<-EOS.undent
      To load SleepWatcher at startup, you will need to install the startup item:

        sudo cp -pR #{prefix}/StartupItems/SleepWatcher /Library/StartupItems/
        sudo chown -R root:wheel /Library/StartupItems/SleepWatcher
      EOS
    end
  end
end
