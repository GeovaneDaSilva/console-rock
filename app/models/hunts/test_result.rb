module Hunts
  # A hunt test's result
  class TestResult < ApplicationRecord
    belongs_to :hunt_result, counter_cache: true
    belongs_to :test
    belongs_to :ttp, optional: true

    has_one :hunt, through: :hunt_result

    scope :ordered_by_test_type, -> { joins(:test).order("hunts_tests.type") }
    scope :positive_indicator, lambda {
      positive.joins(:hunt_result).where(hunt_results: { result: HuntResult.results[:positive] })
    }
    scope :ttp, -> { where.not(ttp_id: nil) }
    scope :feed, -> { joins(:hunt).where.not(hunts: { feed_result: nil }) }
    scope :malicious, -> { positive.joins(:hunt).where(hunts: { indicator: :malicious }) }
    scope :suspicious, -> { positive.joins(:hunt).where(hunts: { indicator: :suspicious }) }
    scope :informational, -> { positive.joins(:hunt).where(hunts: { indicator: :informational }) }

    enum result: {
      positive: 0,
      negative: 1
    }

    def details
      ::TestResults::BaseJson.new(super)
    end
  end
end
