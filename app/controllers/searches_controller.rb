# :nodoc
class SearchesController < AuthenticatedController
  include Pagy::Backend

  def index
    skip_authorization

    respond_to do |format|
      format.html { index_html_response }
      format.js { index_js_response }
    end
  end

  private

  def index_html_response
    results = Searcher.new(params[:query], current_user)
                      .call
    @pagination, @results = pagy results
  end

  def index_js_response
    results = Searcher.new(params[:query], current_user)
                      .call
                      .page(1).per(5).to_a

    # Dance to protect text search ranking
    autocomplete_results = []
    %w[Device Customer Provider].each do |type|
      autocomplete_results << results.select do |result|
        result.searchable_type == type
      end.collect(&:auto_complete_description)
    end

    render json: autocomplete_results.flatten
  end
end
