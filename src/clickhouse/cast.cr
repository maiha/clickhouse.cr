# Entries are manually maintained by checking official document.
# https://clickhouse-docs.readthedocs.io/en/latest/data_types/

module Clickhouse::Cast
  # Numeric values are sometimes returned as String such as "count(*)"
  {% begin %}
  def self.cast(any : JSON::Any, type : String, hint : String)
    case type
    {% for x in [Float32, Float64, Int8, Int16, Int32, Int64, String, Time, UInt8, UInt16, UInt32, UInt64] %}
      when "Array({{x}})"
        any.as_a.map{|a| cast(a, "{{x}}", hint).as({{x}})}
      when "Nullable({{x}})"
        (any.raw.nil? || any.raw == "") ? nil : cast(any, "{{x}}", hint).as({{x}})
    {% end %}
    when "DateTime"
      s = cast(any, "String", hint).as(String)
      Pretty::Time.parse(s, location: ::Time::Location.local)
    when "Date"
      s = cast(any, "String", hint).as(String)
      Pretty::Time.parse(s, location: ::Time::Location.local).at_beginning_of_day
  # Enum
  # FixedString(N)
    when "Float32"
      (any.as_s? ? any.as_s : (any.as_i? ? any.as_i : any.as_f)).to_f32
    when "Float64"
      (any.as_s? ? any.as_s : (any.as_i? ? any.as_i : any.as_f)).to_f64
    when "UInt8"
      if any.as_s?
        case v = any.as_s
        when "true" ; 1_u8
        when "false"; 0_u8
        else        ; v.to_u8
        end
      else            
        any.as_i.to_u8
      end
    when "UInt16"
      (any.as_s? ? any.as_s : any.as_i).to_u16
    when "UInt32"
      (any.as_s? ? any.as_s : any.as_i).to_u32
    when "UInt64"
      (any.as_s? ? any.as_s : any.as_i).to_u64
    when "Int8"
      (any.as_s? ? any.as_s : any.as_i).to_i8
    when "Int16"
      (any.as_s? ? any.as_s : any.as_i).to_i16
    when "Int32"
      (any.as_s? ? any.as_s : any.as_i).to_i32
    when "Int64"
      (any.as_s? ? any.as_s : any.as_i).to_i64
    # Int ranges
  # Uint ranges
    when "String"
      any.raw.nil? ? "" : any.as_s.to_s
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
