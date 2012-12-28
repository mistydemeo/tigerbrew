require 'formula'

class ShellCmds < Formula
  homepage 'http://opensource.apple.com/'
  url 'http://opensource.apple.com/tarballs/shell_cmds/shell_cmds-170.tar.gz'
  sha1 '2036913727cba7816b26812172046fd548ef1f7f'

  def install
    # Currently omits: alias, date, find, hexdump, hostname, id, nohup,
    # path_helper, su, w, who

    # certain tools use a FreeBSD macro Apple names differently
    fbsdids = %w[echo hostname jot killall pwd script seq sleep which]
    %w[apply basename chroot dirname echo env expr false getopt
    hostname jot kill killall lastcomm locate logname mktemp nice
    printenv printf pwd renice script seq shlock sleep tee test
    time true uname users what whereis which yes].each do |tool|
      cd tool do
        if fbsdids.include? tool
          inreplace "#{tool}.c", "__FBSDID", "__RCSID"
        end
        system "make", tool
        bin.install tool

        onepages = Dir['*.1']
        man1.install onepages unless onepages.empty?
        eightpages = Dir['*.8']
        man8.install eightpages unless eightpages.empty?
      end
    end
  end
end

