# :nodoc
class AnalysisMailer < ApplicationMailer
  def complete(analysis)
    @user     = analysis.user
    @analysis = analysis

    mail to: emails_with_names([@user]), subject: analysis_title(@analysis)
  end

  private

  def analysis_title(analysis)
    case analysis
    when Analysis::File
      "Your file analysis for #{analysis.upload.filename} is complete"
    when Analysis::Url
      "Your url analysis for #{analysis.host} is complete"
    end
  end
end
