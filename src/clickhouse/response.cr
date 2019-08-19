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

  # define 'each' directly since 'delegate' fails
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

  # ```crystal
  # res = execute <<-SQL
  #   SELECT   engine, count(*)
  #   FROM     system.tables
  #   GROUP BY engine
  #   SQL
  # records = res.success!.records
  # records.each do |hash|
  #   p hash["engine"]
  # ```
  def records : Array(Record)
    ary = Array(Record).new
    each_hash do |hash|
      ary << hash
    end
    return ary
  end

  # ```crystal
  # res = execute <<-SQL
  #   SELECT   engine, count(*)
  #   FROM     system.tables
  #   GROUP BY engine
  #   SQL
  # records = res.success!.map(String, UInt64)
  # records.each do |(name, cnt)|
  #   p [name, cnt]
  # ```
  def map(*types : *T) forall T
    map{|a|
    {% begin %}
      {% i = 0 %}
      Tuple.new(
        {% for type in T %}
          a[{{i}}].as({{type.instance}}),
          {% i = i + 1 %}
        {% end %}
      )
    {% end %}
    }
  end

  # ```crystal
  # res = execute <<-SQL
  #   SELECT   engine, count(*)
  #   FROM     system.tables
  #   GROUP BY engine
  #   SQL
  # records = res.success!.map(name: String, cnt: UInt64)
  # records.each do |record|
  #   p [record["name"], record["cnt"]]
  # ```
  def map(**types : **T) forall T
    map{|a|
    {% begin %}
      {% i = 0 %}
      NamedTuple.new(
      {% for name, type in T %}
        {{ name }}: a[{{i}}].as({{type.instance}}),
        {% i = i + 1 %}
      {% end %}
      )
    {% end %}
    }
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
