require "./spec_helper"

describe Clickhouse do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  describe "#execute" do
    it "SELECT 1,2" do
      res = client.execute("SELECT 1, 'foo'")
      res.size.should eq(1)
      res.to_a.should eq([[1, "foo"]])
    end
  end
end
