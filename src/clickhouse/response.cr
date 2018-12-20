record Clickhouse::Response,
  uri  : URI,
  req  : Request,
  http : HTTP::Client::Response,
  time : Time::Span

require "./response/**"

struct Clickhouse::Response
  include Enumerable(Array(Type))

  var parsed : JSONCompactParser = JSONCompactParser.from_json(body)
  var data   : Array(Array(JSON::Any)) = parsed.data

  delegate status_code, body, to: http
  delegate each, scalar, meta, data, rows, statistics, to: parsed

  def success? : Response?
    http.success? ? self : nil
  end
  
  def success! : Response
    success? || raise ServerError.parse(body).tap(&.uri= uri)
  end

  def to_json : String
    case req.format
    when OutputFormat::JSONCompact
      JSONCompactParser.data(body)
    else
      body
    end
  end
end
