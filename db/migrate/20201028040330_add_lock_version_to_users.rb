class AddLockVersionToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :lock_version, :bigint,
               default: 0, null: false
  end
end
