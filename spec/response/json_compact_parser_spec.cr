require "../spec_helper"

private def simple_json : String
  <<-EOF
    {
      "meta": [
        { "name": "1", "type": "UInt8" }
      ],
      "data": [
        [ 1 ]
      ],
      "rows": 1,
      "statistics": {
        "elapsed": 0.000671276,
        "rows_read": 1,
        "bytes_read": 1
      }
    }
    EOF
end

describe Clickhouse::Response::JSONCompactParser do
  parsed = Clickhouse::Response::JSONCompactParser.from_json(simple_json)

  describe "#meta" do
    it "returns an array of Field" do
      parsed.meta.map(&.name).should eq(["1"])
      parsed.meta.map(&.type).should eq(["UInt8"])
      parsed.meta.map(&.data_type).should eq([Clickhouse::DataType::UInt8])
    end
  end

  describe "#data" do
    it "returns an array of array of JSON::Any" do
      parsed.data.should be_a(Array(Array(JSON::Any)))
      parsed.data.to_json.should eq("[[1]]")
    end
  end

  describe "#rows" do
    it "returns a count of data" do
      parsed.rows.should eq(1)
    end
  end

  describe "#statistics" do
    it "returns statistics" do
      parsed.statistics.elapsed.should eq(0.000671276)
      parsed.statistics.rows_read.should eq(1)
      parsed.statistics.bytes_read.should eq(1)
    end
  end
end

# `count(*)` returns a string like `[["1"]]` although it has "UInt64" type.
private def count_json : String
  <<-EOF
    {
      "meta": [
        {
          "name": "count()",
          "type": "UInt64"
        }
      ],
      "data": [
        ["1"]
      ],
      "rows": 1,
      "statistics": {
        "elapsed": 0.0010013,
        "rows_read": 0,
        "bytes_read": 0
      }
    }
    EOF
end

describe Clickhouse::Response::JSONCompactParser do
  parsed = Clickhouse::Response::JSONCompactParser.from_json(count_json)

  context "the case of COUNT(*)" do
    it "accepts string as int" do
      parsed.scalar.should eq(1)
    end
  end
end
