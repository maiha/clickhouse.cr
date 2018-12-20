module Clickhouse::Executable
  def before_execute(&callback : (HTTP::Client, HTTP::Request) ->)
    (@before_execute ||= [] of ( (HTTP::Client, HTTP::Request) ->)) << callback
  end

  def execute : Response
    query = Query.build do |qb|
      yield(qb)
    end
    execute(query)
  end
  
  def execute(sql : String) : Response
    execute(Request.new(query: sql))
  end

  def execute(req : Request) : Response
    http_req = HTTP::Request.new("POST", build_query_param, build_headers, body: req.sql)
    http_client = build_http

    @before_execute.try &.each &.call(http_client, http_req)
    
    logger.debug "HTTP request: #{http_req.path}"
    logger.debug "HTTP headers: #{http_req.headers.to_h}"

    started_at = Time.now
    http_res   = http_client.exec(http_req)
    stopped_at = Time.now

    Response.new(uri: uri, req: req, http: http_res, time: (stopped_at - started_at))

  rescue ex : Errno
    raise Clickhouse::CannotConnectError.new("#{ex.class}: #{ex.message}").tap(&.uri= uri)
  end

  private def build_http
    http = HTTP::Client.new(uri)
    http.dns_timeout     = dns_timeout
    http.connect_timeout = connect_timeout
    http.read_timeout    = read_timeout
    http
  end

  private def build_query_param : String
    buf = String.build do |s|
      {% for x in %w( user password database profile ) %}
        if {{x.id}}?
          s << "&{{x.id}}=" << URI.escape({{x.id}})
        end
      {% end %}
      s << "&query="
    end
    buf.sub(/^&/, "/?")
  end
  
  private def host_header
    String.build do |io|
      if host = uri.host
        io << host
      end
      if uri.port && !((uri.scheme == "http" && uri.port == 80) || (uri.scheme == "https" && uri.port = 443))
        io << ':'
        io << uri.port.to_s
      end
    end
  end

  protected def build_headers
    HTTP::Headers{
      "Host"         => host_header,
      "Content-Type" => "application/json",
      "Accept"       => "application/json",
    }
  end
end
