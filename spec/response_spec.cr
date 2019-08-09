require "./spec_helper"

private def sample_response(code = 200) : Clickhouse::Response
  uri  = Clickhouse.new.uri
  req  = Clickhouse::Request.new("SELECT 1")
  http = HTTP::Client::Response.new(code)
  res  = Clickhouse::Response.new(uri, req, http, 0.seconds)
  return res
end

describe Clickhouse::Response do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  it "should be an Enumerable(Array(Type))" do
    res = client.execute("SELECT 1")
    res.should be_a Enumerable(Array(Clickhouse::Type))
  end

  describe "#meta" do
    it "returns an array of Field" do
      res = Clickhouse::Response.mock("UInt8")
      res.meta.map(&.name).should eq(["flag"])
      res.meta.map(&.type).should eq(["UInt8"])
    end
  end

  describe "#data" do
    it "returns an array of array of JSON::Any" do
      res = Clickhouse::Response.mock("UInt8")
      res.data.should be_a(Array(Array(JSON::Any)))
      res.data.to_json.should eq("[[1]]")
    end
  end

  describe "#rows" do
    it "returns a count of data" do
      res = Clickhouse::Response.mock("UInt8")
      res.rows.should eq(1)
    end
  end

  describe "#statistics" do
    it "returns statistics" do
      res = Clickhouse::Response.mock("UInt8")
      res.statistics.elapsed.should eq(0.000671276)
      res.statistics.rows_read.should eq(1)
      res.statistics.bytes_read.should eq(1)
    end
  end
  
  describe "#success?" do
    it "returns self when http is success" do
      res = client.execute("SELECT 1")
      res.success?.should eq(res)
    end

    it "returns nil when http is not success" do
      res = sample_response(code: 500)
      res.success?.should eq(nil)
    end
  end

  describe "#success!" do
    it "returns self when http is success" do
      res = client.execute("SELECT 1")
      res.success!.should eq(res)
    end

    it "raises ServerError when http is not success" do
      res = sample_response(code: 500)
      expect_raises(Clickhouse::ServerError) do
        res.success!
      end
    end
  end

  describe "#scalar" do
    it "returns the first value as Type" do
      res = client.execute("SELECT 'foo'")
      res.scalar.should eq("foo")
    end

    it "for the case of int" do
      res = client.execute("SELECT count(*) FROM system.databases WHERE name = 'default'")
      res.scalar.should eq(1)
    end
  end

  describe "#each_hash" do
    it "iterates all data as hash" do
      got = Array(Array(String)).new
      res = Clickhouse::Response.mock("KVS")
      res.each_hash do |hash|
        got << [hash["key"].to_s, hash["val"].to_s]
      end
      got.should eq([["foo", "1"], ["bar", "2"]])
    end
  end

  context "(TYPES)" do
    # `count(*)` returns a string like `[["1"]]` although it has "UInt64" type.
    it "accepts String as UInt64" do
      res = Clickhouse::Response.mock("UInt64-via-String")
      res.scalar.should eq(1)
    end

    it "accepts String as Int64" do
      res = Clickhouse::Response.mock("Int64-via-String")
      res.scalar.should eq(1)
    end

    it "accepts Array(String)" do
      res = Clickhouse::Response.mock("Array-String")
      res.scalar.should eq(["a", "b"])
    end

    it "accepts Nullable(Int64)" do
      res = Clickhouse::Response.mock("Nullable-Int64")
      res.data.should eq([[nil], [1]])
    end

    it "accepts DateTime" do
      res = Clickhouse::Response.mock("DateTime-via-String")
      v = res.scalar
      v.should be_a(Time)
      t = v.as(Time)
      t.local?.should eq true
      t.to_s("%Y-%m-%d %H:%M:%S").should eq "2000-01-02 03:04:05"
    end

    it "accepts Date" do
      res = Clickhouse::Response.mock("Date-via-String")
      v = res.scalar
      v.should be_a(Time)
      t = v.as(Time)
      t.local?.should eq true
      t.to_s("%Y-%m-%d %H:%M:%S").should eq "2000-01-02 00:00:00"
    end
  end
end
