# The agent sends text in its native character encoding
# Let's tidy those bits up into nice UTF-8
class TidyBits
  include ActiveSupport::Multibyte::Unicode

  def initialize(app)
    @app = app
  end

  # TODO: Update the header that gets checked
  def call(env)
    if env["HTTP_USER_AGENT"] == "RocketAgent" # ENV["CHARSET"] == "ISO-8859-1"
      body = env["rack.input"].read
      tidy_body = tidy_bytes(body, true)
      env["CONTENT_LENGTH"] = tidy_body.bytesize
      env["rack.input"] = StringIO.new(tidy_body)
    end

    @app.call(env)
  end
end
