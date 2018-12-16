class Clickhouse::Response::CountParser
  Jq.mapping({
    data: Array(Array(String)),
  })

  def count? : Int64?
    data.first?.try(&.first?).try(&.to_i64)
  end

  def count : Int64
    count? || raise "count not found"
  end
end

#def count : Int64
#  CountParser.from_json(body).count
#end

#def count? : Int64?
#  CountParser.from_json(body).count?
#end
