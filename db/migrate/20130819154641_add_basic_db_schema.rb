class AddBasicDbSchema < ActiveRecord::Migration

  def change

    create_table :websites do |t|
      t.string :url
      t.boolean :approved 

      t.timestamps
    end

    create_table :pages do |t|
      t.string :url
      t.boolean :needs_crawling
      t.integer :website_id

      t.timestamps
    end

    create_table :words do |t|
      t.integer :page_id
      t.string :word
      t.string :original

      t.timestamps
    end

  end

end
