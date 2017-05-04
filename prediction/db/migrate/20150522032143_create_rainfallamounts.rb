class CreateRainfallamounts < ActiveRecord::Migration
  def change
    create_table :rainfallamounts do |t|
      t.float :maxamount
      t.float :amount

      t.timestamps
    end
  end
end
