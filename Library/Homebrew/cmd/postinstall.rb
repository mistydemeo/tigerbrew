module Homebrew
  def postinstall
    ARGV.resolved_formulae.each { |f| run_post_install(f) }
  end
end
