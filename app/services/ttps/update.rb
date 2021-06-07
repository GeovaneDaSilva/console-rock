module TTPs
  # :nodoc
  class Update
    def call
      new_ttps = []

      doc = Nokogiri::HTML(URI.parse("https://attack.mitre.org/techniques/enterprise/").open)
      table = doc.css("table").first

      table.css("tbody tr").each do |ttp_row|
        url = "http://attack.mitre.org#{ttp_row.css('a').first['href']}/"
        id = ttp_row.children[1].content.strip
        technique = ttp_row.children[3].content.strip

        if !TTP.exists?(id)
          new_ttps << id
          ServiceRunnerJob.perform_later("TTPs::Create", id, technique, url)
        end
      end

      new_ttps
    end
  end
end
