class CreateLegislations < ActiveRecord::Migration[8.0]
  def change
    create_table :legislations do |t|
      t.string :name
      t.text :purpose
      t.text :summary
      t.integer :ideology_score
      t.string :sponsors
      t.string :status
      t.date :proposed_date
      t.date :approved_date
      t.date :enacted_date

      t.timestamps
    end
  end
end
