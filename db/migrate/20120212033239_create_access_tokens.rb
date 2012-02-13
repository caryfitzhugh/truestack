class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.string :key
      t.string :secret

      t.timestamps
    end
  end
end
