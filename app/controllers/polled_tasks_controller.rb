# Polled tasks status
class PolledTasksController < ApplicationController
  def show
    @value = Rails.cache.read("polled-tasks/#{params[:id]}")

    return head :not_found if @value.nil?

    render json: { url: @value }
  end
end
