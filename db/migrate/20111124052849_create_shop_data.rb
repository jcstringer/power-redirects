class CreateShopData < ActiveRecord::Migration
  def self.up
    create_table :shop_data do |t|
      t.string :name
      t.string :api_url

      t.timestamps
    end
  end

  def self.down
    drop_table :shop_data
  end
end
