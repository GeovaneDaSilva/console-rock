# Make a model searchable
# Add this for searchable callbacks (async) and relationship for global index
# Must implement :account and :text_search_blob methods
module Searchable
  extend ActiveSupport::Concern

  included do
    after_save :create_or_update_text_search, if: :index?
    after_destroy :destroy_text_search
  end

  def text_search
    @text_search ||= TextSearch.find_or_initialize_by(
      searchable_id: id.to_s, searchable_type: self.class.name
    )
  end

  private

  def index?
    Rails.application.config.index_models
  end

  def create_or_update_text_search
    text_search.assign_attributes(
      account: account, blob: text_search_blob, auto_complete_description: auto_complete_description
    )

    text_search.save!
  end

  def destroy_text_search
    text_search&.destroy
  end
end
