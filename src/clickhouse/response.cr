record Clickhouse::Response,
  uri  : URI,
  req  : Request,
  http : HTTP::Client::Response,
  time : Time::Span

require "./response/**"

struct Clickhouse::Response
  include Enumerable(Array(Type))

  var parsed : JSONCompactParser = JSONCompactParser.parse(body)
  var data   : Array(Array(JSON::Any)) = parsed.data

  delegate status_code, body, to: http
  delegate meta, data, rows, statistics, to: parsed

  def success? : Response?
    http.success? ? self : nil
  end
  
  def success! : Response
    success? || raise ServerError.parse(body).tap(&.uri= uri)
  end

  def field(i : Int32)
    meta[i]? || raise FieldNotFound.new("no field[#{i}] in #{meta}")
  end

  def each
    data.each do |row|
      vals = row.map_with_index{|any, i|
        cast(any, field(i))
      }
      yield vals
    end
  end

  def scalar : Type
    each do |row|
      if row.size > 0
        return row.first
      else
        raise DataNotFound.new("data[0][0]")
      end
    end
    raise DataNotFound.new("data[0]")
  end

  def to_json : String
    case req.format
    when OutputFormat::JSONCompact
      JSONCompactParser.data(body)
    else
      body
    end
  end

  protected def cast(any : JSON::Any, field : Field) : Type
    Cast.cast(any, field.data_type)
  end
end
