# Nearst value, walking up the parent tree
module Nearestable
  def method_missing(method, *_args, &_blk)
    intended_method = method.to_s.gsub(/^nearest_/, "")
    if method =~ /^nearest_/ && respond_to?(intended_method, "")
      send(intended_method).presence || parent&.send(method)
    else
      super
    end
  end

  def respond_to_missing?(method, *)
    intended_method = method.to_s.gsub(/^nearest_/, "")
    method =~ /^nearest_/ && respond_to?(intended_method, "")
  end
end
