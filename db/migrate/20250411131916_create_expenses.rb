class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.string :title
      t.decimal :amount
      t.date :spent_on
      t.string :category

      t.timestamps
    end
  end
end
