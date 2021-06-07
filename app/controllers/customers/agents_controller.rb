module Customers
  # Customer's devices
  class AgentsController < Customers::CustomersBaseController
    helper_method :template, :customer

    def index
      authorize customer, :deploy_agents?

      @agent_url = api_customer_support_url(customer.license_key, I18n.t("agent.installer_name"))
    end

    def show
      authorize customer, :deploy_agents?

      headers["Content-Disposition"] = %(
        attachment; filename="#{filename}"
      ).squish

      respond_to do |format|
        format.xml
        format.ps1
        format.mws do
          send_data(
            generate_zip,
            type:        "application/zip",
            disposition: "attachment",
            filename:    filename
          )
        end
      end
    end

    private

    def customer
      @customer ||= Customer.find(params[:customer_id])
    end

    def template
      case params[:id]
      when "kaseya"
        "kaseya"
      when "labtech"
        "labtech"
      when "powershell", "syncro", "datto", "solarwinds", "ninja", "barracuda"
        "powershell"
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def filename
      if params[:id] == "barracuda" && params[:format] == "mws"
        "barracuda.mws"
      else
        [
          I18n.t("application.name").parameterize, "agent", customer.name.parameterize,
          "deployment.#{request.format.symbol}"
        ].join("-")
      end
    end

    def generate_zip
      zip_file = Tempfile.new(filename)
      begin
        Zip::OutputStream.open(zip_file) { |zos| }
        Zip::File.open(zip_file.path, Zip::File::CREATE) do |zip|
          ps1_template = "#{params[:id]}.ps1"
          # xml_template = "#{params[:id]}.xml"
          xml_template = "script-meta-data.xml"

          powershell_file = add_to_zip(zip, ps1_template)
          ps1_hash = Digest::MD5.file(powershell_file.path).hexdigest
          add_to_zip(zip, xml_template, { script_file: ps1_template, file_hash: ps1_hash })
        end
        File.read(zip_file.path)
      ensure
        zip_file.close
        zip_file.unlink
      end
    end

    def add_to_zip(zip, template_name, options = {})
      temp_file = Tempfile.new(template_name)
      begin
        content = render_to_string partial: "customers/agents/#{template_name}", locals: options
        temp_file.write(content)
        zip.add(template_name, temp_file.path)
        temp_file
      ensure
        temp_file.close
      end
    end

    def skip_onboarding_redirect?
      true
    end
  end
end
