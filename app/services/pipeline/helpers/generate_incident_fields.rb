module Pipeline
  module Helpers
    # nodoc
    class GenerateIncidentFields
      def self.incident_values(results, template_id = nil)
        @results = results
        @type = results.first&.app&.configuration_type&.to_sym
        @template = ::LogicRules::IncidentTemplate.where(id: template_id).last
        calculate_needed_values

        [title, description, remediation]
      end

      def self.title
        if @template
          interpolate_value(@template.title, @results.first["details"])
        else
          case @type
          when :antivirus
            "#{@av_name} Detection"
          when :cyberterrorist_network_connection
            "Brute Force RDP Attack from #{@country}"
          when :office365_signin
            "Office 365 Malicious Login (Successful)"
          end
        end
      end

      def self.description
        if @template
          interpolate_value(@template.description, @results.first["details"])
        else
          case @type
          when :antivirus
            "The following file was detected by #{@av_name}."
          when :cyberterrorist_network_connection
            "The following connections attempted to log in via RDP, from an IP with a known reputation for #{@threats}."
            # if @failed_count
            #   tmp += "  There were #{@failed_count]} failed login attempts and #{@successful_count]} successful login attempts."
            # end
          when :office365_signin
            "The following account successfully logged in to Office 365 from #{@country}.  This IP has a known reputation for #{@reputation}"
          end
        end
      end

      def self.remediation
        if @template
          interpolate_value(@template.remediation, @results.first["details"])
        else
          case @type
          when :antivirus
            "(1) Run a full scan of the system.  (2) If this file is permitted, whitelist the file."
          when :cyberterrorist_network_connection
            "(1) Place RDP behind a VPN (2) Make sure the system is fully patched (3) Implement strict firewall policies to reduce the attack surface by limiting both inbound and outbound traffic to only necessary ports and protocols  (4) Consider implementing geo-based policies (if possible)"
          when :office365_signin
            "(1) Enable <a href=https://docs.microsoft.com/en-us/microsoft-365/admin/security-and-compliance/set-up-multi-factor-authentication?redirectSourcePath=%252fen-us%252farticle%252f8f0454b2-f51a-4d9c-bcde-2c48e41621c6&view=o365-worldwide>2-Factor Authentication</a> for all users in the tenant
            (2) Add Conditional Access Policies to <a href=https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-location>block undesired logon regions</a>
            (3) <a href=https://blogs.technet.microsoft.com/cloudyhappypeople/2017/10/05/killing-sessions-to-a-compromised-office-365-account/>Kill existing sessions</a>"
          end
        end
      end

      def self.calculate_needed_values
        if %i[sentinelone cylance bitdefender webroot].include?(@type)
          @av_name = @type.dup.to_s.humanize
          @type = :antivirus
        end

        case @type
        when :cyberterrorist_network_connection
          @country = COUNTRIES[@results.first&.details&.country]&.dig("full_name") || "-"
          # @failed_count = 0
          # @successful_count = 1
          @threats = @results.first&.details&.reputation&.dig("threats_found")
        when :office365_signin
          @reputation = @results.first&.details&.location&.dig("threatsFound")&.join(", ")

          @country = if @results.size == 1
                       COUNTRIES[@results.first&.details&.location
                           &.dig("countryOrRegion")]&.dig("full_name") || "-"
                     else
                       "multiple countries"
                     end
        end
      end

      def references
        case @type
        when :office365_signin
          "https://docs.microsoft.com/en-us/microsoft-365/admin/security-and-compliance/set-up-multi-factor-authentication?redirectSourcePath=%252fen-us%252farticle%252f8f0454b2-f51a-4d9c-bcde-2c48e41621c6&view=o365-worldwide>2-Factor Authentication\n
          https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-location\n
          https://blogs.technet.microsoft.com/cloudyhappypeople/2017/10/05/killing-sessions-to-a-compromised-office-365-account/"
        end
      end

      def self.interpolate_value(text, data)
        pattern = /\${(.*?)}/
        text.gsub(pattern) do |match|
          path = match.scan(pattern).flatten.first
          keys = path.split(".")
          data.dig(*keys)
        end
      end
    end
  end
end
