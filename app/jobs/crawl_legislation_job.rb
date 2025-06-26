class CrawlLegislationJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform
    update_progress(0, "Starting legislation analysis")
    
    begin
      total_steps = 4
      current_step = 0
      
      update_progress(25, "Fetching recent legislation")
      LegislationAnalyzer.new.fetch_recent
      current_step += 1
      
      update_progress(50, "Analyzing content")
      LegislationAnalyzer.new.analyze_content
      current_step += 1
      
      update_progress(75, "Scoring ideology")
      LegislationAnalyzer.new.score_ideology
      current_step += 1
      
      update_progress(100, "Completed legislation analysis")
    rescue StandardError => e
      update_progress(-1, "Error: #{e.message}")
      Rails.logger.error "Failed to analyze legislation: #{e.message}"
      raise
    end
  end

  private

  def update_progress(percentage, message)
    Sidekiq.redis do |conn|
      conn.hset(
        "job_progress:#{self.class.name}:#{jid}",
        {
          percentage: percentage,
          message: message,
          updated_at: Time.current.to_i
        }
      )
      # Set expiry to 1 hour
      conn.expire("job_progress:#{self.class.name}:#{jid}", 3600)
    end
  end
end 