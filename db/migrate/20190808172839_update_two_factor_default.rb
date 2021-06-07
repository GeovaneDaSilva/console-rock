class UpdateTwoFactorDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :users, :second_factor_attempts_count, from: nil, to: 0

    reversible do |dir|
      dir.up do
        User.reset_column_information

        User.where(second_factor_attempts_count: nil).update_all(second_factor_attempts_count: 0)
      end
    end
  end
end
