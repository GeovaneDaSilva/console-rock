module CiscoUmbrella
  HTTPError = Class.new(StandardError)
  ConnectionPeerResetError = Class.new(HTTPError)
end
