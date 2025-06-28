class DashboardController < ApplicationController
  def index
    @news_articles = NewsArticle.order(published_at: :desc).limit(10)
    @legislations = Legislation.order(proposed_date: :desc).limit(10)
    @videos = Video.order(created_at: :desc).limit(20)
    @job_stats = Sidekiq::Stats.new
    @active_jobs = active_jobs_with_progress
  end

  def approve_video
    video = Video.find(params[:id])
    video.update!(status: "approved")
    ProduceVideoJob.perform_later(video.id)
    redirect_to root_path, notice: "영상 제작이 시작되었습니다."
  end

  def generate_script
    record_type = params[:record_type]
    record_id = params[:record_id]
    GenerateScriptJob.perform_later(record_type, record_id)
    redirect_to root_path, notice: "스크립트 생성이 시작되었습니다."
  end

  def upload_video
    video = Video.find(params[:id])
    UploadVideoJob.perform_later(video.id)
    redirect_to root_path, notice: "유튜브 업로드가 시작되었습니다."
  end

  def crawl_data
    CrawlNewsJob.perform_later
    CrawlLegislationJob.perform_later
    redirect_to root_path, notice: "데이터 수집이 시작되었습니다."
  end

  def job_progress
    render json: active_jobs_with_progress
  end

  private

  def active_jobs_with_progress
    workers = Sidekiq::Workers.new
    jobs = []

    workers.each do |_process_id, _thread_id, work|
      job_class = work["payload"]["class"]
      jid = work["payload"]["jid"]

      progress = Sidekiq.redis do |conn|
        conn.hgetall("job_progress:#{job_class}:#{jid}")
      end

      next if progress.empty?

      jobs << {
        id: jid,
        class: job_class,
        started_at: Time.at(work["run_at"]).strftime("%Y-%m-%d %H:%M:%S"),
        percentage: progress["percentage"].to_i,
        message: progress["message"],
        updated_at: Time.at(progress["updated_at"].to_i).strftime("%Y-%m-%d %H:%M:%S")
      }
    end

    jobs
  end
end
