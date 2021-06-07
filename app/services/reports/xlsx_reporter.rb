module Reports
  # Generate A XLS from a collection
  class XlsxReporter < ReporterBase
    private

    def finalize
      @finalize ||= s3_file_object.presigned_url(:get, expires_in: 604_800)
    end

    def extract_values(element)
      TabularExtractor.new(element, attrs, ",").call
    end

    # def concat_values(values)
    #   package = Axlsx::Package.new
    #   workbook = package.workbook
    #
    #   workbook.styles do |style|
    #     header_style = style.add_style(header_style_attributes)
    #
    #     workbook.add_worksheet(name: collection_type.to_s.delete(":").humanize.pluralize(2)) do |sheet|
    #       sheet.add_row(headers, style: header_style)
    #
    #       values.each do |row|
    #         sheet.add_row(row.split(","))
    #       end
    #     end
    #   end
    #
    #   package.to_stream
    # end
    #
    # def headers
    #   @options[:header_values].collect do |column_header|
    #     rich_text = Axlsx::RichText.new
    #     rich_text.add_run(column_header.to_s.humanize, b: true)
    #     rich_text
    #   end
    # end

    def attrs
      @options[:attrs]
    end

    def filename
      "reports/#{DateTime.current.to_i}/#{options[:filename] || 'results'}.xlsx"
    end

    def content_type
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end

    def header_style_attributes
      {
        bg_color:  "CCCCCCCC",
        size:      16,
        alignment: { horizontal: :center },
        boder:     { style: :thick, color: "00000000", edges: [:bottom] }
      }
    end
  end
end
