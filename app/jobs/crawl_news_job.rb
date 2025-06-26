class CrawlNewsJob < ApplicationJob
  queue_as :default

  def perform
    update_progress(0, "Starting news crawling")
    
    begin
      total_sources = NewsCrawler::SOURCES.size
      NewsCrawler::SOURCES.each_with_index do |source, index|
        update_progress(
          ((index.to_f / total_sources) * 100).to_i,
          "Crawling #{source}"
        )
        NewsCrawler.new.crawl_source(source)
      end
      
      update_progress(100, "Completed news crawling")
    rescue StandardError => e
      update_progress(-1, "Error: #{e.message}")
      Rails.logger.error "Failed to crawl news: #{e.message}"
      raise
    end
  end

  private

  def update_progress(percentage, message)
    Sidekiq.redis do |conn|
      conn.hset(
        "job_progress:#{self.class.name}:#{job_id}",
        {
          percentage: percentage,
          message: message,
          updated_at: Time.current.to_i
        }
      )
      # Set expiry to 1 hour
      conn.expire("job_progress:#{self.class.name}:#{job_id}", 3600)
    end
  end
end 