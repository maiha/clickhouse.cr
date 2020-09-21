class Clickhouse::Migrate
  class Plan
    var name : String
    var type : Type
    var sql  : String
    var err  : String

    def initialize(@name, @type, @sql = nil, @err = nil)
    end

    def alter_query : String
      if migratable?
        if s = sql?
          return s
        else
          raise "BUG: #{self.class} must have [sql] (#{self})"
        end
      else
        raise ArgumentError.new("column is not migratable")
      end
    end
    
    def migratable? : Bool
      return false if type.nop?
      return false if type.error?
      return true
    end
  end
end
