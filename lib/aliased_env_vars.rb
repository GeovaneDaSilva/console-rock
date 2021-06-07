# This file aliases ENV vars when the value of the ENV var starts with a $
# Heroku doesn't support ENV var aliasing, so we have to do it in ze code
ENV.each do |key, value|
  matcher = value.match(/^\$(.+)/)
  if matcher && ENV[matcher[1]]
    puts "#{key} alias of #{value}, updating assignment"
    ENV[key] = ENV[matcher[1]]
  end
end
