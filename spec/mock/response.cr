struct Clickhouse::Response
  def self.mock(name : String, format : OutputFormat = OutputFormat::JSONCompact) : Response
    req  = Request.new("mock: #{name}", format)
    path = File.join(__DIR__, format.to_s, "#{name}.json")

    if File.exists?(path)
      res = Response.new(URI.new, req, HTTP::Client::Response.new(200), 0.second)
      res.parsed = JSONCompactParser.from_json(File.read(path))
    else
      res = Response.new(URI.new, req, HTTP::Client::Response.new(400), 0.second)
    end
    return res
  end
end
