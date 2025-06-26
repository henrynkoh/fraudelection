class ProduceVideoJob
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(video_id = nil)
    return unless video_id
    
    video = Video.find_by(id: video_id)
    return unless video
    
    update_progress(0, "Starting video production")
    
    begin
      update_progress(20, "Preparing assets")
      update_progress(40, "Generating video frames")
      update_progress(60, "Adding transitions and effects")
      update_progress(80, "Adding audio")
      VideoProducer.new.produce(video)
      update_progress(100, "Completed video production")
    rescue StandardError => e
      update_progress(-1, "Error: #{e.message}")
      Rails.logger.error "Failed to produce video #{video_id}: #{e.message}"
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