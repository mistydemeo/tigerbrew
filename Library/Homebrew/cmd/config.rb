require "hardware"
require "software_spec"
require "rexml/document"

module Homebrew
  def config
    dump_verbose_config
  end

  def llvm
    @llvm ||= MacOS.llvm_build_version if MacOS.has_apple_developer_tools?
  end

  def gcc_42
    @gcc_42 ||= MacOS.gcc_42_build_version if MacOS.has_apple_developer_tools?
  end

  def gcc_40
    @gcc_40 ||= MacOS.gcc_40_build_version if MacOS.has_apple_developer_tools?
  end

  def clang
    @clang ||= MacOS.clang_version if MacOS.has_apple_developer_tools?
  end

  def clang_build
    @clang_build ||= MacOS.clang_build_version if MacOS.has_apple_developer_tools?
  end

  def xcode
    if instance_variable_defined?(:@xcode)
      @xcode
    elsif MacOS::Xcode.installed?
      @xcode = MacOS::Xcode.version
      @xcode += " => #{MacOS::Xcode.prefix}" unless MacOS::Xcode.default_prefix?
      @xcode
    end
  end

  def clt
    if instance_variable_defined?(:@clt)
      @clt
    elsif MacOS::CLT.installed? && MacOS::Xcode.version >= "4.3"
      @clt = MacOS::CLT.version
    end
  end

  def head
    Homebrew.git_head || "(none)"
  end

  def last_commit
    Homebrew.git_last_commit || "never"
  end

  def origin
    Homebrew.git_origin || "(none)"
  end

  def describe_path(path)
    return "N/A" if path.nil?
    realpath = path.realpath
    if realpath == path then path else "#{path} => #{realpath}" end
  end

  def describe_x11
    return "N/A" unless MacOS::XQuartz.installed?
    "#{MacOS::XQuartz.version} => #{describe_path(MacOS::XQuartz.prefix)}"
  end

  def describe_perl
    describe_path(which "perl")
  end

  def describe_python
    python = which "python"
    return "N/A" if python.nil?
    python_binary = Utils.popen_read python, "-c", "import sys; sys.stdout.write(sys.executable)"
    python_binary = Pathname.new(python_binary).realpath
    if python == python_binary
      python
    else
      "#{python} => #{python_binary}"
    end
  end

  def describe_ruby
    ruby = which "ruby"
    return "N/A" if ruby.nil?
    ruby_binary = Utils.popen_read ruby, "-rrbconfig", "-e", \
      'include RbConfig;print"#{CONFIG["bindir"]}/#{CONFIG["ruby_install_name"]}#{CONFIG["EXEEXT"]}"'
    ruby_binary = Pathname.new(ruby_binary).realpath
    if ruby == ruby_binary
      ruby
    else
      "#{ruby} => #{ruby_binary}"
    end
  end

  def hardware
    "CPU: #{Hardware.cores_as_words}-core #{Hardware::CPU.bits}-bit #{Hardware::CPU.family}"
  end

  def kernel
    `uname -m`.chomp
  end

  def macports_or_fink
    @ponk ||= MacOS.macports_or_fink
    @ponk.join(", ") unless @ponk.empty?
  end

  def describe_system_ruby
    s = ""

    if defined? RUBY_PATCHLEVEL
      s << "#{RUBY_VERSION}-#{RUBY_PATCHLEVEL}"
    else
      s << RUBY_VERSION
    end

    if RUBY_PATH.to_s !~ %r{^/System/Library/Frameworks/Ruby.framework/Versions/[12]\.[089]/usr/bin/ruby}
      s << " => #{RUBY_PATH}"
    end
    s
  end

  def describe_java
    # java_home doesn't exist on all OS Xs; it might be missing on older versions.
    return "N/A" unless File.executable? "/usr/libexec/java_home"

    java_xml = Utils.popen_read("/usr/libexec/java_home", "--xml", "--failfast")
    return "N/A" unless $?.success?
    javas = []
    REXML::XPath.each(REXML::Document.new(java_xml), "//key[text()='JVMVersion']/following-sibling::string") do |item|
      javas << item.text
    end
    javas.uniq.join(", ")
  end

  def dump_verbose_config(f = $stdout)
    f.puts "HOMEBREW_VERSION: #{HOMEBREW_VERSION}"
    f.puts "ORIGIN: #{origin}"
    f.puts "HEAD: #{head}"
    f.puts "Last commit: #{last_commit}"
    f.puts "HOMEBREW_PREFIX: #{HOMEBREW_PREFIX}"
    f.puts "HOMEBREW_REPOSITORY: #{HOMEBREW_REPOSITORY}"
    f.puts "HOMEBREW_CELLAR: #{HOMEBREW_CELLAR}"
    f.puts "HOMEBREW_BOTTLE_DOMAIN: #{BottleSpecification::DEFAULT_DOMAIN}"
    f.puts hardware
    f.puts "OS X: #{MACOS_FULL_VERSION}-#{kernel}"
    f.puts "Curl: #{ENV["HOMEBREW_CURL"]}"
    f.puts "Xcode: #{xcode ? xcode : "N/A"}"
    f.puts "CLT: #{clt ? clt : "N/A"}"
    f.puts "GCC-4.0: build #{gcc_40}" if gcc_40
    f.puts "GCC-4.2: build #{gcc_42}" if gcc_42
    f.puts "LLVM-GCC: build #{llvm}"  if llvm
    f.puts "Clang: #{clang ? "#{clang} build #{clang_build}" : "N/A"}"
    f.puts "MacPorts/Fink: #{macports_or_fink}" if macports_or_fink
    f.puts "X11: #{describe_x11}"
    f.puts "System Ruby: #{describe_system_ruby}"
    f.puts "Perl: #{describe_perl}"
    f.puts "Python: #{describe_python}"
    f.puts "Ruby: #{describe_ruby}"
    f.puts "Java: #{describe_java}"
  end
end
