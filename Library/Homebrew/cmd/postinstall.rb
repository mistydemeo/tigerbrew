module Homebrew
  def postinstall
    ARGV.resolved_formulae.each { |f| f.run_post_install }
  end
end
