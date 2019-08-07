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
  delegate scalar, meta, data, rows, statistics, to: parsed

  def each
    parsed.each do |i|
      yield i
    end
  end

  # TODO: optimize
  def each_hash
    keys = meta.map(&.name)
    each do |ary|
      hash = Hash(String, Type?).new
      keys.each_with_index do |k, i|
        hash[k] = ary[i]?
      end
      yield hash
    end
  end

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
