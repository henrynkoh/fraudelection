class Video < ApplicationRecord
  belongs_to :news_article
  belongs_to :legislation
end
