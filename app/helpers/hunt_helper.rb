# :nodoc
module HuntHelper
  def service_state(state)
    case state
    when 1, 3
      "Stopped"
    when 2, 4, 5
      "Running"
    when 6, 7
      "Paused"
    end
  end

  def feed_source(source)
    case source
    when "alien_vault"
      "AlienVault"
    else
      source.to_s.humanize
    end
  end
end
