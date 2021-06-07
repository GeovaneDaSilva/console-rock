# :nodoc
module Hunts
  TEST_TYPES = %w[
    Hunts::FileHashTest Hunts::ServiceTest Hunts::FileNameTest
    Hunts::NetworkConnectionTest Hunts::BrowserVisitTest Hunts::RegistryKeyTest
    Hunts::ProcessHashTest Hunts::ProcessNameTest Hunts::UserTest
    Hunts::EventInCategoryTest Hunts::EventFromSourceTest
    Hunts::EventWithIdTest Hunts::EventWithTypeTest Hunts::YaraTest
    Hunts::DnsCacheTest Hunts::DriverFileNameTest Hunts::DriverFileHashTest
    Hunts::OtherTest
  ].freeze

  ADMIN_TESTS = %w[
    Hunts::OtherTest
  ].freeze

  TEST_TYPES_MAP = {
    "File Hash" => "Hunts::FileHashTest", "File Name" => "Hunts::FileNameTest",
    "Event in Category" => "Hunts::EventInCategoryTest", "Yara" => "Hunts::YaraTest",
    "Browser Visit" => "Hunts::BrowserVisitTest", "Registry Key" => "Hunts::RegistryKeyTest",
    "Process Hash" => "Hunts::ProcessHashTest", "Process Name" => "Hunts::ProcessNameTest",
    "Event with Type" => "Hunts::EventWithTypeTest", "Service" => "Hunts::ServiceTest",
    "Event from Source" => "Hunts::EventFromSourceTest", "Event with ID" => "Hunts::EventWithIdTest",
    "Network Connection" => "Hunts::NetworkConnectionTest", "User Account" => "Hunts::UserTest",
    "DNS Cache Entry" => "Hunts::DnsCacheTest",          "Other" => "Hunts::OtherTest",
    "Driver File Name" => "Hunts::DriverFileNameTest",
    "Driver File Hash" => "Hunts::DriverFileHashTest"
  }.freeze

  def self.table_name_prefix
    "hunts_"
  end
end
