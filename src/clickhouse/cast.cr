record Clickhouse::Cast, any : JSON::Any do
  include Jq::Cast

  def self.cast(any : JSON::Any, type : DataType, hint : String)
    {% begin %}
    case type
      {% for c in Clickhouse::DataType.constants %}
      when Clickhouse::DataType::{{c.id}}
        {% if c == "Boolean" %}
          new(any).cast(Bool)
        {% elsif c == "Date" || c == "DateTime" %}
          new(any).cast(Time)
        {% elsif c == "FixedString" %}
          new(any).cast(String)
        {% elsif c == "UInt64" %}
          # ClickHouse returns "COUNT(*)" as String
          (any.as_s? ? any.as_s : any.as_i).to_u64
        {% elsif c == "Int64" %}
          # Int64 sometimes converted to String for the case of JSON Format
          (any.as_s? ? any.as_s : any.as_i).to_i64
        {% else %}
          new(any).cast({{c.id}})
        {% end %}
      {% end %}
    else
      raise TypeNotSupported.new("unsupported type: '#{type}' (#{hint})")
    end
    {% end %}
  rescue err
    raise CastError.new("#{hint}: #{err}")
  end
end
