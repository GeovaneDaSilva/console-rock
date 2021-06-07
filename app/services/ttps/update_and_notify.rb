module TTPs
  # Update all TTP's and send notification if any new ones are found
  class UpdateAndNotify
    def initialize; end

    def call
      new_ttps = Update.new.call

      return if new_ttps.blank?

      TTPMailer.new_ttps(new_ttps).deliver_later(wait: 5.minutes)
    end
  end
end
