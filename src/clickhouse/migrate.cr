require "./migrate/*"

class Clickhouse::Migrate
  include Enumerable(Plan)

  var src : Array(Column)
  var dst : Array(Column)

  def initialize(@src, @dst)
  end

  def each
    plans.select(&.migratable?).each do |plan|
      yield plan
    end
  end

  def errors : Array(Plan)
    plans.select(&.type.error?)
  end

  def plans : Array(Plan)
    all_names  = (src.map(&.name) | dst.map(&.name))
    named_srcs = src.group_by(&.name)
    named_dsts = dst.group_by(&.name)

    return all_names.map{|name|
      srcs = named_srcs[name]? || Array(Column).new
      dsts = named_dsts[name]? || Array(Column).new
      build_plan(name, srcs, dsts)
    }
  end

  def manifest(colorize : Bool = true, delimiter = "  ", nop_msg = "# NOP", err_msg = "# ERROR: %s") : String
    lines = Array(Array(String)).new
    index = 0
    recipe = ->(name : String, msg : String, color : Symbol?) {
      index += 1
      if (c = color) && colorize
        lines << [index.to_s.colorize(c), name.colorize(c), msg.colorize(c)].map(&.to_s)
      else
        lines << [index.to_s, name, msg]
      end
    }
      
    plans.each do |plan|
      case plan.type
      when .nop?
        recipe.call(plan.name, nop_msg, nil)
      when .error?
        recipe.call(plan.name, err_msg % plan.err?.to_s, :red)
      when .add?
        recipe.call(plan.name, plan.alter_query, :green)
      else
        recipe.call(plan.name, plan.alter_query, :yellow)
      end
    end
    return Pretty.lines(lines, delimiter: delimiter)
  end

  private def build_plan(name, srcs, dsts)
    if srcs.size > 1
      return Plan.new(name, Type::ERROR, err: "src contains duplicated columns named [name}]")
    end

    if dsts.size > 1
      return Plan.new(name, Type::ERROR, err: "dst contains duplicated columns named [name}]")
    end

    src = srcs.first?
    dst = dsts.first?
    
    if src && dst
      if src.type == dst.type
        return Plan.new(name, Type::NOP)
      else
        return Plan.new(name, Type::MODIFY, sql: "MODIFY COLUMN `#{name}` #{dst.type}")
      end
    end

    if src && dst.nil?
      return Plan.new(name, Type::DROP, sql: "DROP COLUMN `#{name}`")
    end
    
    if src.nil? && dst
      return Plan.new(name, Type::ADD, sql: "ADD COLUMN `#{name}` #{dst.type}")
    end

    raise "BUG: #{self.class}#plans got empty columns for [#{name}]"
  end
end
