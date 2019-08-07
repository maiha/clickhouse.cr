# Entries are manually maintained by checking official document.
# https://clickhouse-docs.readthedocs.io/en/latest/data_types/

record Clickhouse::Cast, any : JSON::Any do
  include Jq::Cast
  
  {% begin %}
  def self.cast(any : JSON::Any, type : String, hint : String)
    case type
    {% for x in [Float32, Float64, Int8, Int16, Int32, Int64, String, Time, UInt8, UInt16, UInt32, UInt64] %}
      when "Array({{x}})"
        any.as_a.map{|a| cast(a, "{{x}}", hint).as({{x}})}
    {% end %}
    when "Date", "DateTime"
      new(any).cast(Time)
  # Enum
  # FixedString(N)
    when "Float32"
      (any.as_s? ? any.as_s : any.as_f).to_f32
    when "Float64"
      (any.as_s? ? any.as_s : any.as_f).to_f64
    when "UInt8"
      new(any).cast(UInt8)
    when "UInt16"
      new(any).cast(UInt16)
    when "UInt32"
      new(any).cast(UInt32)
    when "UInt64"
      # sometimes returns as String such as "count(*)"
      (any.as_s? ? any.as_s : any.as_i).to_u64
    when "Int8"
      new(any).cast(Int8)
    when "Int16"
      new(any).cast(Int16)
    when "Int32"
      new(any).cast(Int32)
    when "Int64"
      # sometimes returns as String such as JSON Format
      (any.as_s? ? any.as_s : any.as_i).to_i64
    # Int ranges
  # Uint ranges
    when "String"
      new(any).cast(String)
  # Tuple(T1, T2, ...)
  # Nested data structures
  # AggregateFunction(name, types_of_arguments...)
  # Nested(Name1 Type1, Name2 Type2, ...)
  # Special data types
  # Expression
  # Set
    else
      raise TypeNotSupported.new("unsupported type: '#{type}' (#{hint})")
    end
  rescue err
    raise CastError.new("#{hint}: #{err}")
  end
  {% end %}
end
