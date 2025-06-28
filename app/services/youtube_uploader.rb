require "google/apis/youtube_v3"

class YouTubeUploader
  def upload(video)
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.client_options.application_name = "FraudElectionFacts"
    youtube.authorization = authorize

    source = video.news_article || video.legislation
    video_snippet = Google::Apis::YoutubeV3::VideoSnippet.new(
      title: generate_title(source),
      description: generate_description(source),
      tags: generate_tags(source),
      category_id: "25" # News & Politics
    )

    video_status = Google::Apis::YoutubeV3::VideoStatus.new(
      privacy_status: "public",
      self_declared_made_for_kids: false
    )

    video_object = Google::Apis::YoutubeV3::Video.new(
      snippet: video_snippet,
      status: video_status
    )

    youtube.insert_video(
      "snippet,status",
      video_object,
      upload_source: video.video_path,
      content_type: "video/mp4"
    ) do |result, err|
      if err
        video.update!(status: "failed")
        raise err
      else
        video.update!(youtube_id: result.id, status: "uploaded")
      end
    end
  rescue StandardError => e
    video.update!(status: "failed")
    Rails.logger.error("YouTube upload failed: #{e.message}")
  end

  private

  def authorize
    client_secrets = Google::APIClient::ClientSecrets.load
    auth_client = client_secrets.to_authorization
    auth_client.update!(
      scope: "https://www.googleapis.com/auth/youtube.upload",
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
    )
    auth_client.refresh!
    auth_client
  end

  def generate_title(source)
    if source.is_a?(NewsArticle)
      "#{source.title} | 부정선거 팩트체크"
    else
      "#{source.name} | 입법 분석"
    end
  end

  def generate_description(source)
    base_description = if source.is_a?(NewsArticle)
                        "#{source.summary}\n\n출처: #{source.source} (#{source.url})"
    else
                        "#{source.purpose}\n\n발의자: #{source.sponsors}\n상태: #{source.status}"
    end

    <<~DESCRIPTION
      #{base_description}

      구독하세요: youtube.com/@FraudElectionFacts
      X(Twitter): twitter.com/FraudElectionFacts

      *정보는 참고용이며, 개인 판단이 필요합니다.
      #FraudElection #부정선거 #팩트체크
    DESCRIPTION
  end

  def generate_tags(source)
    base_tags = [ "Fraud Election", "Election Facts", "부정선거", "팩트체크" ]
    if source.is_a?(NewsArticle)
      base_tags + [ "News", "Politics", source.source ]
    else
      base_tags + [ "Legislation", "Law", "입법", "국회" ]
    end
  end
end
