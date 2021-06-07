# :nodoc
module Chargeable
  def filename
    "#{I18n.t('application.name', default: 'ACME, Inc').parameterize}-#{charge.id}"
  end
end
