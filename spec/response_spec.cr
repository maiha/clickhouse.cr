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
end
