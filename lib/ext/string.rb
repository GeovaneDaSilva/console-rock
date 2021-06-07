# :nodoc
class String
  def exclude_invalid_characters!
    invalid_characters = [
      "\u0000" # null bytes
    ]

    invalid_characters.each { |ic| delete! ic }
    self
  end
end
