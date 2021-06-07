# Simplifies making http calls
module HttpHelper
  # include ErrorHelper

  def patch_call(url, headers, query, body); end

  def pagination(method, url, headers, query = {}, body = {}); end

  def make_api_call(url, headers, query = {}, body = {}, method = "get")
    request = HTTPI::Request.new
    request.url = url
    request.headers = headers
    request.query = query if query.present?
    request.body = body if body.present?

    if method == "get"
      HTTPI.get(request)
    elsif method == "put"
      HTTPI.put(request)
    elsif method == "patch"
      patch_call(url, headers, query, body)
    elsif method == "post"
      HTTPI.post(request)
    end
    # return if resp.code > 299
    #
    # JSON.parse(resp.raw_body)
  end
end
