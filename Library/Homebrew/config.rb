if ENV["HOMEBREW_BREW_FILE"]
  # Path to `bin/brew` main executable in {HOMEBREW_PREFIX}
  HOMEBREW_BREW_FILE = Pathname.new(ENV["HOMEBREW_BREW_FILE"])
else
  odie "HOMEBREW_BREW_FILE was not exported! Please call bin/brew directly!"
end

# Where we link under
HOMEBREW_PREFIX = Pathname.new(HOMEBREW_BREW_FILE).dirname.parent

# Where .git is found
HOMEBREW_REPOSITORY = Pathname.new(HOMEBREW_BREW_FILE).realpath.dirname.parent

HOMEBREW_LIBRARY = HOMEBREW_REPOSITORY/"Library"
HOMEBREW_CONTRIB = HOMEBREW_REPOSITORY/"Library/Contributions"

# Where we store built products; /usr/local/Cellar if it exists,
# otherwise a Cellar relative to the Repository.
HOMEBREW_CELLAR = if (HOMEBREW_PREFIX+"Cellar").exist?
  HOMEBREW_PREFIX+"Cellar"
else
  HOMEBREW_REPOSITORY+"Cellar"
end

# Where downloads (bottles, source tarballs, etc.) are cached
HOMEBREW_CACHE = Pathname.new(ENV["HOMEBREW_CACHE"])

# Where brews installed via URL are cached
HOMEBREW_CACHE_FORMULA = HOMEBREW_CACHE/"Formula"

# Where build, postinstall, and test logs of formulae are written to
HOMEBREW_LOGS = Pathname.new(ENV["HOMEBREW_LOGS"] || "~/Library/Logs/Homebrew/").expand_path

HOMEBREW_TEMP = Pathname.new(ENV.fetch("HOMEBREW_TEMP", "/tmp"))

unless defined? HOMEBREW_LIBRARY_PATH
  HOMEBREW_LIBRARY_PATH = Pathname.new(__FILE__).realpath.parent.join("Homebrew")
end

HOMEBREW_LOAD_PATH = HOMEBREW_LIBRARY_PATH
