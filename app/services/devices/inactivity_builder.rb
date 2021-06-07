module Devices
  # Intended for the payload of inactivity email
  class InactivityBuilder
    def initialize(devices, account, format = :text, type = :inactive_device)
      @devices = devices
      @format = format
      @account = account
      @type = type
    end

    def call
      if @type == :syslog
        @format == :text ? render_syslog_text : render_syslog_html
      else
        @format == :text ? render_text : render_html
      end
    end

    private

    def render_syslog_text
      <<-STR
        The following device in account #{@account.name} were being used as your Syslog Server for the Firewall Monitor and is now offline:\r\n
        #{@devices.map(&:hostname).join("\r\n")}\r\n

        The Firewall Monitor app cannot report results as long as this device remains offline.\r\n
      STR
    end

    def render_syslog_html
      <<-STR
        The following device in account #{@account.name} were being used as your <b>Syslog Server</b> for the Firewall Monitor and is now offline:<br/><br/>
        #{@devices.map(&:hostname).join("\r\n")}<br/><br/>

        The Firewall Monitor app cannot report results as long as this device remains offline.\r\n
      STR
    end

    def render_text
      <<-STR
        The following device(s) in account #{@account.name} have exceeded the inactivity threshold.\r\n
        #{@devices.map(&:hostname).join("\r\n")}
      STR
    end

    def render_html
      <<-STR
        The following device(s) in account <b>#{@account.name}</b> have exceeded the inactivity threshold.<br/><br/>
        #{@devices.map(&:hostname).join("\r\n")}
      STR
    end
  end
end
