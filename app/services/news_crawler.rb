require "nokogiri"
require "httparty"
require "twitter"

class NewsCrawler
  RSS_FEEDS = [
    "https://www.reuters.com/world/us/feed/",
    "https://www.yonhapnews.co.kr/rss/politics",
    "https://rss.donga.com/politics.xml",
    "https://www.chosun.com/arc/outboundfeeds/rss/category/politics/",
    "https://www.hankyung.com/feed/politics"
  ]

  TWITTER_ACCOUNTS = [
    "ElectionNews",
    "PoliticsWatch",
    "ElectionUpdates"
  ]

  def initialize
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def crawl
    articles = crawl_rss + crawl_twitter
    articles.each do |article|
      next if NewsArticle.exists?(url: article[:url])
      next if article[:published_at] < 5.years.ago

      NewsArticle.create!(
        title: article[:title],
        summary: article[:summary],
        url: article[:url],
        source: article[:source],
        published_at: article[:published_at]
      )
    end
  rescue StandardError => e
    Rails.logger.error("News crawling failed: #{e.message}")
  end

  private

  def crawl_rss
    articles = []
    RSS_FEEDS.each do |feed|
      response = HTTParty.get(feed, timeout: 10)
      xml = Nokogiri::XML(response.body)
      xml.xpath("//item").each do |item|
        title = item.xpath("title").text
        next unless title.match?(/election|fraud|voter|부정선거|선거|투표/i)
        articles << {
          title: title,
          summary: item.xpath("description").text[0..200],
          url: item.xpath("link").text,
          source: extract_source_from_feed(feed),
          published_at: Time.parse(item.xpath("pubDate").text)
        }
      end
    end
    articles
  end

  def crawl_twitter
    articles = []
    TWITTER_ACCOUNTS.each do |account|
      tweets = @twitter_client.user_timeline(account, count: 100)
      tweets.each do |tweet|
        next unless tweet.text.match?(/election|fraud|voter|부정선거|선거|투표/i)
        articles << {
          title: tweet.text[0..100],
          summary: tweet.text,
          url: "https://twitter.com/#{account}/status/#{tweet.id}",
          source: "Twitter/#{account}",
          published_at: tweet.created_at
        }
      end
    end
    articles
  end

  def extract_source_from_feed(feed)
    case feed
    when /reuters/ then "Reuters"
    when /yonhap/ then "Yonhap News"
    when /donga/ then "Dong-A Ilbo"
    when /chosun/ then "Chosun Ilbo"
    when /hankyung/ then "Korea Economic Daily"
    else "Other"
    end
  end
end
