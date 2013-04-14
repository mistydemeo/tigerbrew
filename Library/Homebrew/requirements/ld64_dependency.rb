require 'requirements'

# This special dependency ensures that the Tigerbrew ld64
# formula is used as gcc's ld in place of the old version
# that comes with the OS.
class LD64Dependency < Requirement
  env { ENV.ld64 }

  satisfy { Formula.factory('ld64').installed? }

  # note that usually this dependency wouldn't be called
  # without a hard dep on the ld64 formula itself
  def message; <<-EOS.undent
    Unsatisfied dependency: please `brew install ld64`
    EOS
  end
end

