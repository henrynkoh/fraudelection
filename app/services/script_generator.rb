require "crewai"

class ScriptGenerator
  def initialize
    @crew = setup_crew
  end

  def generate_for_news(news)
    task = create_news_task(news)
    script = @crew.execute(task)

    news.videos.create!(script: script, status: "pending")
  rescue StandardError => e
    Rails.logger.error("News script generation failed: #{e.message}")
  end

  def generate_for_legislation(legislation)
    task = create_legislation_task(legislation)
    script = @crew.execute(task)

    legislation.videos.create!(script: script, status: "pending")
  rescue StandardError => e
    Rails.logger.error("Legislation script generation failed: #{e.message}")
  end

  def generate_pending
    NewsArticle.where.not(id: Video.select(:news_article_id))
              .where("published_at > ?", 1.month.ago)
              .find_each do |news|
      generate_for_news(news)
    end

    Legislation.where.not(id: Video.select(:legislation_id))
               .where("proposed_date > ?", 1.month.ago)
               .find_each do |legislation|
      generate_for_legislation(legislation)
    end
  end

  private

  def setup_crew
    CrewAI::Crew.new(
      agents: [
        create_researcher_agent,
        create_writer_agent,
        create_editor_agent
      ]
    )
  end

  def create_researcher_agent
    CrewAI::Agent.new(
      role: "Research Analyst",
      goal: "Analyze news and legislation for key points and implications",
      backstory: "Expert in political analysis and fact-checking",
      tools: [ CrewAI::Tools::WebBrowser.new ]
    )
  end

  def create_writer_agent
    CrewAI::Agent.new(
      role: "Script Writer",
      goal: "Create engaging and informative scripts for short videos",
      backstory: "Experienced in creating viral social media content",
      tools: []
    )
  end

  def create_editor_agent
    CrewAI::Agent.new(
      role: "Content Editor",
      goal: "Ensure scripts are accurate, engaging, and within platform guidelines",
      backstory: "Expert in social media content guidelines and fact-checking",
      tools: []
    )
  end

  def create_news_task(news)
    CrewAI::Task.new(
      description: "Create a 30-45 second script about election fraud news",
      context: {
        title: news.title,
        summary: news.summary,
        source: news.source,
        url: news.url,
        published_at: news.published_at
      }
    )
  end

  def create_legislation_task(legislation)
    CrewAI::Task.new(
      description: "Create a 30-45 second script about election-related legislation",
      context: {
        name: legislation.name,
        purpose: legislation.purpose,
        summary: legislation.summary,
        ideology_score: legislation.ideology_score,
        sponsors: legislation.sponsors,
        status: legislation.status,
        dates: {
          proposed: legislation.proposed_date,
          approved: legislation.approved_date,
          enacted: legislation.enacted_date
        }
      }
    )
  end

  def format_script(raw_script)
    <<~SCRIPT
      #{raw_script}

      더 자세한 내용은 구독으로 확인하세요!

      *이 내용은 참고용이며, 시청자 여러분의 개별적인 판단이 필요합니다.
      #부정선거 #팩트체크 #정치
    SCRIPT
  end
end
