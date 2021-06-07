# add any missing TTPs
module AddMissingTTPs
  module_function

  def call
    missing.each do |ttp|
      create(ttp)
    end
  end

  def missing
    base = APP_CONFIGS.dig(:advanced_breach_detection, :enabled_ttps).keys
    macos = APP_CONFIGS.dig(:advanced_breach_detection, :macos_enabled_ttps).keys
    configured = base + macos
    existing = TTP.all.pluck(:id)

    configured - existing
  end

  def create(ttp)
    attrs = { id: ttp, tactic: "fake tactic", technique: "fake technique",
              description: "fake description", url: "http://www.example.com/fake-ttp",
              remediation: "some fake remediation steps" }
    TTP.create(attrs)
  end
end

namespace :ttps do
  desc "Updates ttps"
  task update: :environment do
    TTPs::Update.new.call
  end

  desc "Add missing TTPs (development only)"
  task add_missing: :environment do
    Rails.env.development? && AddMissingTTPs.call
  end
end
