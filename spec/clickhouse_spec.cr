require "./spec_helper"

describe Clickhouse do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  describe "#execute" do
    it "SELECT 1,2" do
      res = client.execute("SELECT 1, 'foo'")
      res.to_a.should eq([[1, "foo"]])
    end

    it "raises CannotConnectError when it can't connect to server" do
      expect_raises(Clickhouse::CannotConnectError) do
        client = Clickhouse.new(port: 4)
        client.execute("SELECT 1")
      end
    end
  end
end
