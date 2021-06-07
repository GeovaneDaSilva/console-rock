namespace :accounts do
  desc "Convert a single Provider into a multi-plan configuration"
  task :distributorify, %i[account_id] => :environment do |_task, args|
    account = Account.find(args[:account_id])
    Accounts::Distributorify.new(account).call
  end
end
