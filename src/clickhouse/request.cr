record Clickhouse::Request,
  query  : String,
  format : OutputFormat = OutputFormat::JSONCompact do

  def sql : String
    case @query
    when /\sFORMAT\s+([a-z]+)\s*\Z/mi
      @query
    else
      @query + " FORMAT #{format}"
    end
  end
end
