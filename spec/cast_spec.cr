require "./spec_helper"

private macro cast(type, val, exp)
  it "{{type}} from " + {{val.stringify}} do
    Clickhouse::Cast.cast(JSON::Any.new({{val}}), "{{type}}", "#{__FILE__}:#{__LINE__}").should eq({{exp}})
  end
end

describe Clickhouse::Cast do
  cast String, "a", "a"

  cast Int8 , 1_i64, 1_i8
  cast Int8 , "1"  , 1_i8
  cast Int16, 1_i64, 1_i16
  cast Int16, "1"  , 1_i16
  cast Int32, 1_i64, 1_i32
  cast Int32, "1"  , 1_i32
  cast Int64, 1_i64, 1_i64
  cast Int64, "1"  , 1_i64

  cast UInt8 , 1_i64, 1_u8
  cast UInt8 , "1"  , 1_u8
  cast UInt16, 1_i64, 1_u16
  cast UInt16, "1"  , 1_u16
  cast UInt32, 1_i64, 1_u32
  cast UInt32, "1"  , 1_u32
  cast UInt64, 1_i64, 1_u64
  cast UInt64, "1"  , 1_u64

  cast Float32, 1_i64, 1_f32
  cast Float32, 1_f64, 1_f32
  cast Float32, "1"  , 1_f32
  cast Float32, "1.1", 1.1_f32

  cast Float64, 1_i64, 1_f64
  cast Float64, 1_f64, 1_f64
  cast Float64, "1"  , 1_f64
  cast Float64, "1.1", 1.1_f64

  # bool
  cast UInt8 , "true" , 1_u8
  cast UInt8 , "false", 0_u8

  cast DateTime, "2000-01-02T03:04:05Z", Pretty.now(2000,1,2,3,4,5)
  cast DateTime, "2000-01-02T03:04:05" , Pretty.now(2000,1,2,3,4,5)
  cast Date    , "2000-01-02"          , Pretty.now(2000,1,2)

  cast String, "foo", "foo"
  cast String, ""   , ""
  cast String, nil  , ""
end
