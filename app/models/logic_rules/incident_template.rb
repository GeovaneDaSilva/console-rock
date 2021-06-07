module LogicRules
  # Incident template for Logic Rule action
  class IncidentTemplate < ActionTemplate
    attr_json_accessor :details, :title, :description, :remediation
  end
end
