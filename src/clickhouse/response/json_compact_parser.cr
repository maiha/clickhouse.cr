class Clickhouse::Response::JSONCompactParser
  class Field
    Jq.mapping({
      name: String, # "id"
      type: String, # "UInt8"
    })

    def data_type : DataType
      v = type.sub(/\(\d+\)/, "")
      DataType.parse?(v) || raise TypeNotSupported.new("column(#{name}) has unsupported type: '#{type}'")
    end
  end  
  
  Jq.mapping({
    meta: Array(Field),
    data: Array(Array(JSON::Any)),
  })

  def self.parse(body : String)
    from_json(body)
  end

  def self.data(body : String) : String
    Jq.new(body)[".data"].any.to_json
  end
end
