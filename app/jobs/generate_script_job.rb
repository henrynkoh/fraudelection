class GenerateScriptJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(news_id = nil, legislation_id = nil)
    update_progress(0, "Starting script generation")
    
    begin
      if news_id
        news = NewsArticle.find_by(id: news_id)
        if news
          update_progress(25, "Analyzing news article")
          update_progress(50, "Generating script draft")
          update_progress(75, "Reviewing and finalizing")
          ScriptGenerator.new.generate_for_news(news)
          update_progress(100, "Completed script generation")
        else
          update_progress(-1, "Error: News article not found")
        end
      elsif legislation_id
        legislation = Legislation.find_by(id: legislation_id)
        if legislation
          update_progress(25, "Analyzing legislation")
          update_progress(50, "Generating script draft")
          update_progress(75, "Reviewing and finalizing")
          ScriptGenerator.new.generate_for_legislation(legislation)
          update_progress(100, "Completed script generation")
        else
          update_progress(-1, "Error: Legislation not found")
        end
      else
        update_progress(25, "Finding pending items")
        update_progress(50, "Generating scripts")
        ScriptGenerator.new.generate_pending
        update_progress(100, "Completed script generation")
      end
    rescue StandardError => e
      update_progress(-1, "Error: #{e.message}")
      Rails.logger.error "Failed to generate script (news_id: #{news_id}, legislation_id: #{legislation_id}): #{e.message}"
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