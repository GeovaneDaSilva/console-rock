namespace :onetime do
  desc "Fix Syncro Credentials base urls"
  task fix_syncro_credentials_base_url: :environment do
    Integrations::Syncro::FixBaseUrls.new.call
  end
end
