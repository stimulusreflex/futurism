class CreateActionItems < ActiveRecord::Migration[6.0]
  def change
    create_table :action_items do |t|
      t.string :description

      t.timestamps
    end
  end
end
