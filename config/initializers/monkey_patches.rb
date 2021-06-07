# Reopen and add methods to the Object class
class Object
  def tap!
    # rubocop:disable
    yield self
    # rubocop:enable
  end
end
