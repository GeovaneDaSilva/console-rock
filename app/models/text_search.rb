# Represents a single table with the search index data
# of many different models
class TextSearch < ApplicationRecord
  belongs_to :account
  belongs_to :searchable, polymorphic: true

  def self.fuzzy_search(*args)
    ActiveRecord::Base.connection.execute("SELECT set_limit(0.0001);")
    super
  end

  def blob=(val)
    super val.downcase
  end
end
