MoneyRails.configure do |config|
  config.default_format = {
    no_cents_if_whole: false
  }

  config.no_cents_if_whole = false
  config.locale_backend = :i18n
end
