module Analysis
  # File analysis object
  class File < Analyze
    attr_json_accessor :resource, :upload_id
    delegate :clear?, :suspicious?, :compromise?, :permalink, :confidence, :threat_name, to: :results

    validates :upload_id, presence: true

    def upload
      @upload ||= Upload.find(upload_id)
    end

    private

    def results
      @results ||= Opswat::Hash.new(Threats::Lookup::Hash.new(upload.md5).call)
    end
  end
end
