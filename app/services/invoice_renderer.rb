# Render a charge invoice as PDF
class InvoiceRenderer
  include Chargeable

  attr_reader :charge

  def initialize(charge)
    @charge = charge
  end

  def call
    BreezyPDFLite::RenderRequest.new(html).to_file
  end

  private

  def locals
    {
      charge:   @charge,
      account:  @charge.account,
      plan:     @charge.plan,
      filename: filename
    }
  end

  def html
    @html ||= Accounts::ChargesController.render(:show, locals: locals).squish
  end
end
