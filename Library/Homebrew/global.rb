require 'rbconfig'
require 'extend/dir'
require 'extend/module'
require 'extend/fileutils'
require 'extend/hash'
require 'extend/pathname'
require 'extend/ARGV'
require 'extend/string'
require 'extend/symbol'
require 'extend/enumerable'
require 'os'
require 'utils'
require 'exceptions'
require 'set'
require 'extend/tiger' if RUBY_VERSION == '1.8.2'
require 'extend/leopard' if RUBY_VERSION <= '1.8.6'
require 'rbconfig'

ARGV.extend(HomebrewArgvExtension)

HOMEBREW_VERSION = '0.9.5'
HOMEBREW_WWW = 'https://github.com/mistydemeo/tigerbrew'

require "config"

RbConfig = Config if RUBY_VERSION < "1.8.6" # different module name on Tiger

if RbConfig.respond_to?(:ruby)
  RUBY_PATH = Pathname.new(RbConfig.ruby)
else
  RUBY_PATH = Pathname.new(RbConfig::CONFIG["bindir"]).join(
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]
  )
end
RUBY_BIN = RUBY_PATH.dirname

if RUBY_PLATFORM =~ /darwin/
  MACOS_FULL_VERSION = `/usr/bin/sw_vers -productVersion`.chomp
  MACOS_VERSION = MACOS_FULL_VERSION[/10\.\d+/]
  OS_VERSION = "Mac OS X #{MACOS_FULL_VERSION}"
else
  MACOS_FULL_VERSION = MACOS_VERSION = "0"
  OS_VERSION = RUBY_PLATFORM
end

HOMEBREW_GITHUB_API_TOKEN = ENV["HOMEBREW_GITHUB_API_TOKEN"]
HOMEBREW_USER_AGENT = "Tigerbrew #{HOMEBREW_VERSION} (Ruby #{RUBY_VERSION}; #{OS_VERSION})"

HOMEBREW_CURL_ARGS = '-f#LA'

require 'tap_constants'

module Homebrew
  include FileUtils
  extend self

  attr_accessor :failed
  alias_method :failed?, :failed
end

HOMEBREW_PULL_OR_COMMIT_URL_REGEX = %r[https://github\.com/([\w-]+)/tigerbrew(-[\w-]+)?/(?:pull/(\d+)|commit/[0-9a-fA-F]{4,40})]

require 'compat' unless ARGV.include? "--no-compat" or ENV['HOMEBREW_NO_COMPAT']

ORIGINAL_PATHS = ENV['PATH'].split(File::PATH_SEPARATOR).map{ |p| Pathname.new(p).expand_path rescue nil }.compact.freeze
