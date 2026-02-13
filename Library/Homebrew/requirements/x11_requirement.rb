require "requirement"

class X11Requirement < Requirement
  include Comparable
  attr_reader :min_version

  fatal true
  download "https://xquartz.macosforge.org"

  env { ENV.x11 }

  def initialize(name = "x11", tags = [])
    @name = name
    if /(\d\.)+\d/ === tags.first
      @min_version = Version.new(tags.shift)
      @min_version_string = " #{@min_version}"
    else
      @min_version = Version.new("0.0.0")
      @min_version_string = ""
    end
    super(tags)
  end

  satisfy :build_env => false do
    MacOS::XQuartz.installed? && min_version <= Version.new(MacOS::XQuartz.version)
  end

  def message
    name = MacOS.version == :tiger ? "X11" : "XQuartz"

    s = "#{name}#{@min_version_string} is required to install this formula."

    if MacOS.version == :tiger
      s += "You can install it using the X11 installer located in the"
      s += "\"Optional Installs\" folder on your Mac OS X 10.4 DVD."
    elsif MacOS.version == :leopard
      s += "You can install it from the XQuartz website:"
      s += "https://www.xquartz.org/releases/XQuartz-2.6.3.html"
    elsif MacOS.version <= :mountain_lion
      s += "You can install it from the XQuartz website:"
      s += "https://www.xquartz.org/releases/XQuartz-2.7.11.html"
    else
      s += "You can install it from the XQuartz website:"
      s += "https://www.xquartz.org/releases/index.html"
    end
  end

  def <=>(other)
    return unless X11Requirement === other
    min_version <=> other.min_version
  end

  def eql?(other)
    super && min_version == other.min_version
  end

  def inspect
    "#<#{self.class.name}: #{name.inspect} #{tags.inspect} min_version=#{min_version}>"
  end
end
