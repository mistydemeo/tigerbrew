module Homebrew
  def postinstall
    ARGV.resolved_formulae.select(&:post_install_defined?).each { |f| f.run_post_install }
  end
end
