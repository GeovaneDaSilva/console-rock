module Credentials
  # :nodoc
  class Syncro < Credential
    before_save :append_api_v1
    validates :base_url,
              presence: true,
              format:   {
                with:    /\A(http|https)?:\/\/[a-zA-Z0-9\-\.]+\.[a-z]{2,4}/,
                message: "invalid Syncro base url"
              }

    def append_api_v1
      return unless base_url && !base_url.include?("api/v1")

      self.base_url = [base_url.chomp("/"), "api/v1"].join("/")
    end
  end
end
