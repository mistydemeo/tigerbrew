module Homebrew
  def postinstall
    ARGV.resolved_formulae.each { |f| f.run_post_install if f.post_install_defined? }
  end
end
