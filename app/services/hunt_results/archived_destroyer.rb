module HuntResults
  # :nodoc
  class ArchivedDestroyer
    def call
      HuntResult.archived.where("updated_at < ?", 2.weeks.ago).find_each(&:destroy)
    end
  end
end
