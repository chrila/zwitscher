class AddPicUrlToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :pic_url, :string
  end
end
