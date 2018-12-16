require "./spec_helper"

describe Clickhouse::Cast do
  describe "supports all data types in DataType" do
    {% for c in Clickhouse::DataType.constants %}
      it "{{c.id}}" do
        begin
          Clickhouse::Cast.cast(JSON::Any.new(nil), Clickhouse::DataType::{{c.id}})
        rescue
          # It's ok because runtime error means that the compilation has been passed.
        end
      end
    {% end %}
  end
end
