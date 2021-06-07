# :nodoc
module PostApiCallProcessor
  extend ActiveSupport::Concern

  def credential
    @cred || @credential
  end

  def credential_is_working(response)
    self.class.credential_is_working(credential, response)
  end

  # :nodoc
  module ClassMethods
    def credential_is_working(credential, response)
      if credential && (credential.is_working.nil? || (credential.updated_at + 5.minutes) < Time.current)
        code = response&.code
        credential.is_working = code < 300
        credential.updated_at = Time.current
        credential.save
      end
      response
    end
  end
end
