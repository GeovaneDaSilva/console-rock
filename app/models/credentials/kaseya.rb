module Credentials
  # :nodoc
  class Kaseya < Credential
    TICKET_SOURCES = {
      "Client Portal"     => 0,
      "Phone"             => 1,
      "In Person"         => 2,
      "On Site"           => 3,
      "Email"             => 4,
      "Monitoring System" => 5,
      "Voice Mail"        => 6,
      "Verbal"            => 7,
      "Other"             => 8,
      "Recurring"         => 9
    }.freeze
  end
end
