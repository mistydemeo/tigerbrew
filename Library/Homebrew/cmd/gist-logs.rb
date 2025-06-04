require "formula"
require "cmd/config"
require "net/http"
require "net/https"
require "stringio"

module Homebrew
  def gistify_logs(f)
    files = load_logs(f.logs)

    s = StringIO.new
    Homebrew.dump_verbose_config(s)
    files["config.out"] = { :content => s.string }
    files["doctor.out"] = { :content => `brew doctor 2>&1` }
    unless f.core_formula?
      tap = <<-EOS.undent
        Formula: #{f.name}
        Tap: #{f.tap}
        Path: #{f.path}
      EOS
      files["tap.out"] = { :content => tap }
    end

    url = create_gist(files)

    if ARGV.include?("--new-issue") || ARGV.switch?("n")
      url = new_issue(f.tap, "#{f.name} failed to build on #{MACOS_FULL_VERSION}", url)
    end

    puts url if url
  end

  # Hack for ruby < 1.9.3
  def noecho_gets
    system "stty -echo"
    result = $stdin.gets
    system "stty echo"
    puts
    result
  end

  def load_logs(dir)
    logs = {}
    dir.children.sort.each do |file|
      contents = file.size? ? file.read : "empty log"
      logs[file.basename.to_s] = { :content => contents }
    end if dir.exist?
    raise "No logs." if logs.empty?
    logs
  end

  def create_gist(files)
    post("/gists", "public" => true, "files" => files)["html_url"]
  end

  def new_issue(repo, title, body)
    post("/repos/#{repo}/issues", { "title" => title, "body" => body })["html_url"]
  end

  def http
    @http ||= begin
      uri = URI.parse("https://api.github.com")
      p = ENV["http_proxy"] ? URI.parse(ENV["http_proxy"]) : nil
      if p.class == URI::HTTP || p.class == URI::HTTPS
        @http = Net::HTTP.new(uri.host, uri.port, p.host, p.port, p.user, p.password)
      else
        @http = Net::HTTP.new(uri.host, uri.port)
      end
      @http.use_ssl = true
      @http
    end
  end

  def make_request(path, data)
    headers = {
      "User-Agent"    => HOMEBREW_USER_AGENT_CURL,
      "Accept"        => "application/vnd.github.v3+json",
      "Content-Type"  => "application/json",
      "Authorization" => "token #{HOMEBREW_GITHUB_API_TOKEN}"
    }

    request = Net::HTTP::Post.new(path, headers)
    request.body = Utils::JSON.dump(data)
    request
  end

  def post(path, data)
    request = make_request(path, data)

    case response = http.request(request)
    when Net::HTTPCreated
      Utils::JSON.load get_body(response)
    else
      raise "HTTP #{response.code} #{response.message} (expected 201)"
    end
  end

  def get_body(response)
    if !response.body.respond_to?(:force_encoding)
      response.body
    elsif response["Content-Type"].downcase == "application/json; charset=utf-8"
      response.body.dup.force_encoding(Encoding::UTF_8)
    else
      response.body.encode(Encoding::UTF_8, :undef => :replace)
    end
  end

  def gist_logs
    if ARGV.resolved_formulae.length != 1
      puts "usage: brew gist-logs [--new-issue|-n] <formula>"
      Homebrew.failed = true
      return
    end

    unless HOMEBREW_GITHUB_API_TOKEN
      puts "Create a personal Github access token at: https://github.com/settings/tokens"
      puts "and then set the environment variable HOMEBREW_GITHUB_API_TOKEN to its value."
      return
    end

    gistify_logs(ARGV.resolved_formulae[0])
  end
end
