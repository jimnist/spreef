class SpreeRefineryUserModifications < ActiveRecord::Migration
  def change
    create_table :spree_refinery_user_plugins do |t|
      t.integer :user_id
      t.string :name
      t.integer :position

      t.timestamps
    end


  end
end
