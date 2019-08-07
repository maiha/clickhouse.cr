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
      req = Clickhouse::Request.new("SQL")
      res = Clickhouse::Response.new(URI.new, req, HTTP::Client::Response.new(200), 0.second)
      
      res.parsed = Clickhouse::Response::JSONCompactParser.from_json(<<-EOF)
        {
          "meta": [{"name": "key", "type": "String"},{"name": "val", "type": "String"}],
          "data": [["foo","1"],["bar","2"]]
        }
        EOF

      got = Array(Array(String)).new
      res.each_hash do |hash|
        got << [hash["key"].to_s, hash["val"].to_s]
      end
      got.should eq([["foo", "1"], ["bar", "2"]])
    end
  end
end
