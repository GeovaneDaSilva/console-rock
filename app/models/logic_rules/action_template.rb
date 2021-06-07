module LogicRules
  # Template for Logic Rule actions
  class ActionTemplate < ApplicationRecord
    include AttrJsonable

    validates :name, presence: true

    def titleized_type
      type&.split("::")&.last&.titleize || "Action Template"
    end
  end
end
