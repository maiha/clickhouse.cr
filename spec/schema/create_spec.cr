require "./spec_helper"

private def normalize_string(s : String) : String
  s.gsub(/\n/m, " ").gsub(/\s+/, " ")
end

describe Clickhouse::Schema::Create do
  describe ".parse(string)" do
    it "builds a new instance from the string" do
      buf = <<-EOF
        CREATE TABLE IF NOT EXISTS default.logs (
          date Date,
          hour Int32,
          imp Int64
        ) ENGINE = Merge(currentDatabase(), '^logs_')
        EOF

      schema = Clickhouse::Schema::Create.parse(buf)
      schema.create?.should eq("CREATE TABLE IF NOT EXISTS")
      schema.db?.should eq("default")
      schema.table?.should eq("logs")
      schema.column.gsub(/\s+/m, " ").strip.should eq((<<-EOF).gsub(/\s+/m, " "))
        date Date,
        hour Int32,
        imp Int64
        EOF
      schema.columns.map(&.to_s).should eq(["date Date", "hour Int32", "imp Int64"])
      schema.engine?.should eq("Merge(currentDatabase(), '^logs_')")

      normalize_string(schema.to_sql).should eq(normalize_string(buf))
    end
  end
end
