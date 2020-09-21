require "./spec_helper"

private def empty
  Array(Clickhouse::Column).new
end

private def column(name, type)
  Clickhouse::Column.new(name, type)
end

class Clickhouse
  describe Migrate do
    it "(inputs are empty)" do
      migrate = Migrate.new(empty, empty)
      migrate.plans.should be_empty
      migrate.map(&.alter_query).should be_empty
      migrate.errors.should be_empty
    end

    it "(inputs are the same)" do
      src = dst = column("id","Int32")
      migrate = Migrate.new([src], [dst])
      migrate.plans.map(&.type).should eq([Migrate::Type::NOP])
      migrate.map(&.alter_query).should be_empty
      migrate.errors.should be_empty
    end

    it "(type changed)" do
      src = column("id","Int32")
      dst = column("id","Int64")
      migrate = Migrate.new([src], [dst])
      migrate.plans.map(&.type).should eq([Migrate::Type::MODIFY])
      migrate.map(&.alter_query).should eq(["MODIFY COLUMN `id` Int64"])
      migrate.errors.should be_empty
    end

    it "(src is missing)" do
      dst = column("id","Int64")
      migrate = Migrate.new(empty, [dst])
      migrate.plans.map(&.type).should eq([Migrate::Type::ADD])
      migrate.map(&.alter_query).should eq(["ADD COLUMN `id` Int64"])
      migrate.errors.should be_empty
    end

    it "(dst is missing)" do
      src = column("id","Int64")
      migrate = Migrate.new([src], empty)
      migrate.plans.map(&.type).should eq([Migrate::Type::DROP])
      migrate.map(&.alter_query).should eq(["DROP COLUMN `id`"])
      migrate.errors.should be_empty
    end

    it "(inputs contain duplicated columns)" do
      srcs = [column("id","Int32"), column("id","String")]
      migrate = Migrate.new(srcs, empty)
      migrate.plans.map(&.type).should eq([Migrate::Type::ERROR])
      migrate.map(&.alter_query).should be_empty
      migrate.errors.map(&.type).should eq([Migrate::Type::ERROR])
    end

    it "#manifest" do
      srcs = [column("id","Int32"), column("name","String"), column("age","Int32")]
      dsts = [column("id","Int64"), column("name","String"), column("hobby","String")]

      migrate = Migrate.new(srcs, dsts)
      puts
      puts migrate.manifest
      migrate.manifest(colorize: false).should eq <<-EOF
        1  id     MODIFY COLUMN `id` Int64
        2  name   # NOP
        3  age    DROP COLUMN `age`
        4  hobby  ADD COLUMN `hobby` String
        EOF
    end
  end
end
