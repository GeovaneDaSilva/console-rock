# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with
# db:setup).
#
Rails.cache.clear

puts "Updating all ttps..."
if ENV["REVIEW_APP"]
  Rake::Task["ttps:update"].invoke
  Rake::Task["ttps:add_missing"].invoke
else
  `rails ttps:update` # Shell out so that bg jobs aren't run inline, db:seed overrides the bg queue adapter
  `rails ttps:add_missing` # Shell out so that bg jobs aren't run inline, db:seed overrides the bg queue adapter
end

puts "Updating all apps..."
Rake::Task["apps:seed"].invoke

puts "Creating Users, Plans, Providers, and Customers..."

User.create(
  name: "Admin User", email: "admin@console.test", password: "123456", password_confirmation: "123456",
  admin_role: :omnipotent, accepted_tos_at: DateTime.current
)

Plan.create(
  name: "Free",
  description: "All the great RocketCyber essentials for getting started offering differentiated cyber security services to your clients",
  frequency: :monthly,
  price_per_frequency: 0,
  published: true,
  price_per_device_overage: 0,
  on_demand_analysis_types: %w[file url],
  on_demand_hunt_types: %w[processname url filename filehash],
  apps: App.where(title: ["Basic Breach Detection", "Cyber Terrorist Network Connections", "Malicious File Detection"])
)

pro = Plan.create(
  name: "Professional",
  description: "Ready to step up your game? Subscribe to this plan and pick up a whole new bag of security tricks to offer your clients.",
  frequency: :monthly,
  price_per_frequency: 0,
  published: true,
  included_devices: 0,
  price_per_device_overage: 1,
  apps: App.all.ga.paid,
  on_demand_analysis_types: %w[file url],
  on_demand_hunt_types: %w[processname url filename filehash]
)

Plan.create(
  name: "Managed Endpoint Detection & Response",
  description: "Includes RocketCyber SOC monitoring of devices for suspicious and malicious activity, reviewing events and alerting via your preferred method (email or PSA integration) of incidents that require attention or remediation actions.",
  frequency: :monthly,
  price_per_frequency: 0,
  published: true,
  included_devices: 0,
  price_per_device_overage: 3,
  on_demand_analysis_types: %w[file url],
  on_demand_hunt_types: %w[processname url filename filehash],
  managed: true,
  apps: App.ga.paid
)

owner = User.create(
  name: "Owner 1", email: "owner@console.test", accepted_tos_at: DateTime.current,
  password: "123456", password_confirmation: "123456"
)

viewer_attrs = { name: "Viewer 1", email: "viewer@console.test", password: "123456", password_confirmation: "123456" }
viewer = User.invite!(viewer_attrs) do |u|
  u.invited_by = owner
  u.skip_invitation = true
end

subscribed_root = Provider.create(
  name: "Subscribed Root", plan: pro, paid_thru: 10.days.from_now,
  card_payment_method_token: "fake-valid-visa-nonce", card_masked_number: "401288******1881",
  card_type: "Visa"
)

subscribed_root.user_roles.create(user: owner, role: :owner)
subscribed_root.user_roles.create(user: viewer, role: :viewer)

App.all.each do |app|
  subscribed_root.account_apps.create(app: app, enabled_at: Time.now)
end

subordinate = Provider.create(name: "Subordinate", path: subscribed_root.path)

trial_root = Provider.create(name: "Trial Root")
trial_root.user_roles.create(user_id: owner.id, role: :owner)

medium_customer = Customer.create(name: "Medium customer", path: subordinate.path)
small_customer = Customer.create(name: "Small customer", path: subordinate.path)
trial_customer = Customer.create(name: "Trial customer", path: trial_root.path)

[medium_customer, small_customer, trial_customer].each do |customer|
  Seed::EgressIps.new(customer, amount: SecureRandom.rand(1..5)).call

  puts "Creating Devices..."
  Seed::Devices.new(customer, amount: SecureRandom.rand(10..50)).call

  10.times do
    BillableInstance.line_item_types.keys.each do |line_item_type|
      BillableInstance.create(
        line_item_type: line_item_type, account_path: customer.path,
        external_id: SecureRandom.hex, details: {}
      )
    end
  end
end

puts "Creating app results..."
Rake::Task["app_results:seed"].invoke

puts "Updating support files..."
Rake::Task["support_files:update"].invoke

puts "All done! 💯🎉"
