module Reports
  module Group
    # Base class for group based reporters
    class GroupBase
      def initialize(group, per_page = 10)
        @group = group
        @per_page = per_page
      end
    end
  end
end
