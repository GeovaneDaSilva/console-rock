# Top-level namespace for various Seed services. Also contains a few helper
# class methods
module Seed
  def self.random_times(range = 0..3, &block)
    SecureRandom.rand(range).times(&block)
  end

  def self.random_record(scope)
    scope.order("RANDOM()").first
  end
end
