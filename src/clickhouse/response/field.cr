struct Clickhouse::Response::Field
  Jq.mapping({
    name: String, # "id"
    type: String, # "UInt8"
  })

#  def data_type : DataType
#    v = type.sub(/\(\d+\)/, "")
#    DataType.parse?(v) || raise TypeNotSupported.new("column(#{name}) has unsupported type: '#{type}'")
#  end

  def to_s(io : IO)
    io << "#{name}(#{type})"
  end
end
