class CreateSearches < ActiveRecord::Migration[7.1]
  def change
    create_table :searches do |t|
      t.text :content
      t.string :user_session
      t.string :ip_address

      t.timestamps
    end
  end
end
