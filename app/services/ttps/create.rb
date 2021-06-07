module TTPs
  # :nodoc
  class Create
    def initialize(id, technique, url)
      @id        = id
      @technique = technique
      @url       = url
    end

    def call
      TTP.create(
        id:          @id,
        technique:   @technique,
        tactic:      tactic,
        description: description,
        url:         @url
      )
    end

    private

    def ttp_doc
      @ttp_doc ||= Nokogiri::HTML(URI.parse(@url).open)
    end

    def description
      ttp_doc.css(".description-body").first.content.strip.gsub(/\[\d+\]/, "")
    end

    def tactic
      tactic_card = ttp_doc.css(".card-data").find do |card_data_el|
        card_data_el.content.include?("Tactic")
      end

      tactic_card.content.split(": ").last
    end
  end
end
