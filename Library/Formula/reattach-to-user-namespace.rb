class ReattachToUserNamespace < Formula
  desc "Reattach process (e.g., tmux) to background"
  homepage "https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard"
  url "https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard/archive/v2.4.tar.gz"
  sha256 "645dfb77933fdb89b5935cbfc03f136c2672f8500e0a68b72acb7a1bf552a240"

  head "https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard.git"


  option "with-wrap-pbcopy-and-pbpaste", "Include wrappers for pbcopy/pbpaste that shim in this fix"
  option "with-wrap-launchctl", "Include wrapper for launchctl with this fix"
  deprecated_option "wrap-pbcopy-and-pbpaste" => "with-wrap-pbcopy-and-pbpaste"
  deprecated_option "wrap-launchctl" => "with-wrap-launchctl"

  def install
    system "make"
    bin.install "reattach-to-user-namespace"
    wrap_pbpasteboard_commands if build.with? "wrap-pbcopy-and-pbpaste"
    wrap_launchctl if build.with? "wrap-launchctl"
  end

  def wrap_pbpasteboard_commands
    make_executable_with_content("pbcopy", "cat - | reattach-to-user-namespace /usr/bin/pbcopy")
    make_executable_with_content("pbpaste", "reattach-to-user-namespace /usr/bin/pbpaste")
  end

  def wrap_launchctl
    make_executable_with_content("launchctl", 'reattach-to-user-namespace /bin/launchctl "$@"')
  end

  def make_executable_with_content(executable_name, content_lines)
    executable = bin.join(executable_name)
    content = [*content_lines].unshift("#!/bin/sh").join("\n")
    executable.write(content)
    executable.chmod(0755)
  end

  test do
    system bin/"reattach-to-user-namespace", "-l", "bash", "-c", "echo Hello World!"
  end
end
