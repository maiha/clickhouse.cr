class Clickhouse::Response::JSONCompactParser
  Jq.mapping({
    meta: Array(Field),
    data: Array(Array(JSON::Any)),
    rows: Int64,
    statistics: Statistics,
  })

  def self.parse(body : String)
    from_json(body)
  end

  def self.data(body : String) : String
    Jq.new(body)[".data"].any.to_json
  end
end
