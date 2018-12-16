record Clickhouse::Cast, any : JSON::Any do
  include Jq::Cast
    
  def self.cast(any : JSON::Any, type : DataType)
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
        {% else %}
          new(any).cast({{c.id}})
        {% end %}
      {% end %}
    else
      raise TypeNotSupported.new("unsupported type: '#{type}'")
    end
    {% end %}
  end
end
