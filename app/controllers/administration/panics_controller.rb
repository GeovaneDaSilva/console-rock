require "panic"

module Administration
  # :nodoc
  class PanicsController < BaseController
    def index
      authorize(:administration, :view_crash_reports?)

      @panics = relation.all.sort! do |a, b|
        b.created_at <=> a.created_at
      end
    end

    def show
      authorize(:administration, :view_crash_reports?)

      @panic = relation.find(params[:id])
    end

    def destroy
      authorize(:administration, :view_crash_reports?)

      relation.find(params[:id]).destroy

      redirect_to administration_panics_path
    end

    private

    def relation
      @relation ||= ::PanicRelation.new(OpenStruct.new(id: "panic"))
    end
  end
end
