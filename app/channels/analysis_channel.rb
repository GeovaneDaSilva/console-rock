# Broacast the analysis' status
class AnalysisChannel < ApplicationCable::Channel
  def subscribed
    super

    stream_from channel_name
  end

  private

  def channel_name
    "analysis:#{analysis.id}"
  end

  def analysis
    @analysis ||= Analyze.find(params[:id])
  end
end
