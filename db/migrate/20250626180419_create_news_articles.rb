class CreateNewsArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :news_articles do |t|
      t.string :title
      t.text :summary
      t.string :url
      t.string :source
      t.datetime :published_at

      t.timestamps
    end
  end
end
