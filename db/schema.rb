# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_26_180421) do
  create_table "legislations", force: :cascade do |t|
    t.string "name"
    t.text "purpose"
    t.text "summary"
    t.integer "ideology_score"
    t.string "sponsors"
    t.string "status"
    t.date "proposed_date"
    t.date "approved_date"
    t.date "enacted_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news_articles", force: :cascade do |t|
    t.string "title"
    t.text "summary"
    t.string "url"
    t.string "source"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "videos", force: :cascade do |t|
    t.integer "news_article_id", null: false
    t.integer "legislation_id", null: false
    t.string "script"
    t.string "video_path"
    t.string "thumbnail_path"
    t.string "youtube_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legislation_id"], name: "index_videos_on_legislation_id"
    t.index ["news_article_id"], name: "index_videos_on_news_article_id"
  end

  add_foreign_key "videos", "legislations"
  add_foreign_key "videos", "news_articles"
end
