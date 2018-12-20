require "../spec_helper"

private def json : String
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
  parsed = Clickhouse::Response::JSONCompactParser.parse(json)

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
