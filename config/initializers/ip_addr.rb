# Moneky-patch of built in class
class IPAddr
  def to_cidr_s
    return unless @addr

    mask = @mask_addr.to_s(2).count("1")
    if mask == 32
      to_s
    else
      "#{self}/#{mask}"
    end
  end
end
