module Rack
  # Throttling of bad requests
  class Attack
    ### Configure Cache ###

    # If you don't want to use Rails.cache (Rack::Attack's default), then
    # configure it here.
    #
    # Note: The store is only used for throttling (not blacklisting and
    # whitelisting). It must implement .increment and .write like
    # ActiveSupport::Cache::Store

    # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Spammy Clients ###

    # If any single client IP is making tons of requests, then they're
    # probably malicious or a poorly-configured scraper. Either way, they
    # don't deserve to hog all of the app server's CPU. Cut them off!
    #
    # Note: If you're serving assets through rack, those requests may be
    # counted by rack-attack and this throttle may be activated too
    # quickly. If so, enable the condition to exclude them from tracking.

    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"

    ### Prevent Brute-Force Login Attacks ###

    # The most common brute-force login attack is a brute-force password
    # attack where an attacker simply tries a large number of emails and
    # passwords to see if any credentials match.
    #
    # Another common method of attack is to use a swarm of computers with
    # different IPs to try brute-forcing a password for a specific account.

    # Throttle POST requests to /login by IP address
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
    throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == "/users/sign_in" && req.post?
    end

    # Throttle POST requests to /users/sign_in by email param
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
    #
    # Note: This creates a problem where a malicious user could intentionally
    # throttle logins for another user and force their login requests to be
    # denied, but that's not very common and shouldn't happen to you. (Knock
    # on wood!)
    throttle("logins/email", limit: 5, period: 20.seconds) do |req|
      req.params["email"].presence if req.path == "/users/sign_in" && req.post?
    end

    # Throttle POST requests to /users by IP
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:signups:#{req.email}"
    #
    throttle("logins/sign_up", limit: 10, period: 1.hour) do |req|
      req.ip if req.path == "/users" && req.post?
    end

    ### Custom Throttle Response ###

    throttle("api/panic", limit: 5, period: 5.minutes) do |req|
      req.ip if req.path.match(/\/api\/panic/) && req.post?
    end

    # By default, Rack::Attack returns an HTTP 429 for throttled responses,
    # which is just fine.
    #
    # If you want to return 503 so that the attacker might be fooled into
    # believing that they've successfully broken your app (or you just want to
    # customize the response), then uncomment these lines.
    # self.throttled_response = lambda do |env|
    #  [ 503,  # status
    #    {},   # headers
    #    ['']] # body
    # end

    # Block suspicious requests for '/etc/password' or wordpress or cgi specific paths.
    # After 3 blocked requests in 10 minutes, block all requests from that IP for 5 minutes.
    Rack::Attack.blocklist("fail2ban pentesters") do |req|
      # `filter` returns truthy value if request fails, or if it's from a previously banned IP
      # so the request is blocked
      Rack::Attack::Fail2Ban.filter(
        "pentesters-#{req.ip}",
        maxretry: 3,
        findtime: 10.minutes,
        bantime:  1.hour
      ) do
        # The count for the IP is incremented if the return value is truthy
        CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
          req.path.include?("/etc/passwd") ||
          req.path.include?("wp-admin") ||
          req.path.include?("wp-login") ||
          req.path.include?("cgi") ||
          req.path.include?("php")
      end
    end
  end
end
