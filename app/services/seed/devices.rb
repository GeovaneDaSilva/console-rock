module Seed
  # Service to create one or more demo Device records
  class Devices
    def initialize(customer, amount:)
      @customer = customer
      @range = 1..amount
    end

    def call
      @range.each do |index|
        device = @customer.devices.create(random_attributes(index))

        5.times do |m_index|
          device.connectivity_logs.create(
            connected_at: m_index.months.ago, disconnected_at: (m_index.months.ago + 15.days)
          )
        end
      end
    end

    def random_attributes(index)
      {
        hostname:                  "CONSOLEDEMO-#{index}",
        ipv4_address:              "10.10.10.#{index}",
        mac_address:               random_mac,
        username:                  "console",
        id:                        Digest::MD5.hexdigest(SecureRandom.hex(10)),
        fingerprint:               Digest::MD5.hexdigest(SecureRandom.hex(10)),
        inventory_last_updated_at: DateTime.current,
        egress_ip_id:              @customer.egress_ips.sample.id,
        account_path:              @customer.path
      }.merge(send(%i[windows_attrs macos_attrs].sample))
    end

    def windows_inventory_upload
      @windows_inventory_upload ||= Uploads::Builder.new(
        Rails.root.join("windows_inventory.json").to_s, protected: true
      ).call
    end

    def macos_inventory_upload
      @macos_inventory_upload ||= Uploads::Builder.new(
        Rails.root.join("macos_inventory.json").to_s, protected: true
      ).call
    end

    def random_mac
      SecureRandom.hex(6).split("").in_groups_of(2).collect(&:join).join(":").upcase
    end

    def windows_attrs
      {
        platform:         "Microsoft",
        family:           "Windows",
        edition:          "Professional",
        version:          SecureRandom.rand(7..10),
        architecture:     %w[32-bit x64 ia32].sample,
        build:            SecureRandom.rand(1000..10_000),
        inventory_upload: windows_inventory_upload
      }
    end

    def macos_attrs
      {
        platform:         "Apple",
        family:           "macOS",
        edition:          "Catalina",
        version:          "10.15.2",
        architecture:     "x64",
        build:            "19C57",
        inventory_upload: macos_inventory_upload
      }
    end
  end
end
