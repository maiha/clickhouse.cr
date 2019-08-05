require "./spec_helper"

describe Clickhouse do
  client = Clickhouse.new(host: CLICKHOUSE_HOST, port: CLICKHOUSE_PORT)

  it "(prepare)" do
    tbl = "test.maiha_crystal_test"
      
    client.execute(<<-EOF).success!
      CREATE DATABASE IF NOT EXISTS test
      EOF
      
    client.execute(<<-EOF).success!
      DROP TABLE IF EXISTS #{tbl}
      EOF
      
    client.execute(<<-EOF).success!
      CREATE TABLE #{tbl}
      (
        date Date,
        value Array(UInt32)
      )
      ENGINE = MergeTree(date, date, 8192)
      EOF
  end
  
  describe "#databases" do
    it "returns Array(Database)" do
      names = client.databases.map(&.name)
      names.should contain("default")
      names.should contain("system")
    end
  end
  
  describe "#database(name)" do
    it "returns Database" do
      db = client.database("test")
      names = db.tables.map(&.name)
      names.should contain("maiha_crystal_test")
    end
  end
  
  describe "#table(db, name)" do
    it "returns Table" do
      table = client.table("test", "maiha_crystal_test")
      columns = table.columns
      columns.map(&.name).should eq(["date", "value"])
      columns.map(&.type).should eq(["Date", "Array(UInt32)"])
    end
  end
end
