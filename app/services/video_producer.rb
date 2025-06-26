require 'httparty'
require 'tempfile'

class VideoProducer
  PEXELS_API_URL = 'https://api.pexels.com/videos/search'
  UNSPLASH_API_URL = 'https://api.unsplash.com/photos/random'

  def produce(video)
    script = video.script
    record = video.news_article || video.legislation

    # Generate TTS audio
    generate_audio(script)

    # Download media assets
    download_stock_video
    download_background_images

    # Generate video with MoviePy
    generate_video(video)

    # Update video record
    video.update!(
      video_path: "public/videos/#{video.id}_final.mp4",
      thumbnail_path: "public/thumbnails/#{video.id}_thumb.png",
      status: 'produced'
    )
  rescue StandardError => e
    video.update!(status: 'failed')
    Rails.logger.error("Video production failed: #{e.message}")
  ensure
    cleanup_temp_files
  end

  private

  def generate_audio(script)
    # Generate Korean TTS with more natural voice
    system("gtts-cli '#{script}' --lang ko --slow --output tmp/audio_raw.mp3")
    
    # Add background music and adjust audio levels
    system(<<~COMMAND)
      ffmpeg -i tmp/audio_raw.mp3 -i assets/background_music.mp3 \
        -filter_complex "[0:a]volume=1.0[a1];[1:a]volume=0.1[a2];[a1][a2]amix=inputs=2:duration=first" \
        tmp/audio.mp3
    COMMAND
  end

  def download_stock_video
    # Get multiple relevant videos for variety
    response = HTTParty.get(
      PEXELS_API_URL,
      headers: { 'Authorization' => ENV['PEXELS_API_KEY'] },
      query: { query: 'election politics democracy', per_page: 3 }
    )

    response['videos'].each_with_index do |video, index|
      video_url = video['video_files'].first['link']
      system("curl -o tmp/stock_video_#{index}.mp4 '#{video_url}'")
    end
  end

  def download_background_images
    # Get relevant background images
    3.times do |i|
      response = HTTParty.get(
        UNSPLASH_API_URL,
        headers: { 'Authorization' => "Client-ID #{ENV['UNSPLASH_API_KEY']}" },
        query: { query: 'politics election', orientation: 'portrait' }
      )

      image_url = response['urls']['full']
      system("curl -o tmp/background_#{i}.jpg '#{image_url}'")
    end
  end

  def generate_video(video)
    python_script = <<~PYTHON
      from moviepy.editor import VideoFileClip, TextClip, CompositeVideoClip, AudioFileClip, ImageClip
      from moviepy.video.tools.segmenting import findObjects
      from moviepy.video.fx.all import resize, fadein, fadeout, crossfadein
      import textwrap

      def create_text_clip(text, duration, font_size=50, color='white'):
          # Wrap text for better readability
          lines = textwrap.wrap(text, width=25)
          text_clip = TextClip('\\n'.join(lines),
                             fontsize=font_size,
                             color=color,
                             bg_color='rgba(0,0,0,0.5)',
                             font='NanumGothic',
                             size=(1080, None),
                             method='caption')
          return text_clip.set_duration(duration)

      # Load audio and calculate duration
      audio = AudioFileClip("tmp/audio.mp3")
      total_duration = audio.duration

      # Load video clips
      video_clips = [VideoFileClip(f"tmp/stock_video_{i}.mp4").resize(height=1920) for i in range(3)]
      
      # Load background images
      image_clips = [ImageClip(f"tmp/background_{i}.jpg").resize(height=1920) for i in range(3)]

      # Create clips list for final composition
      clips = []
      current_time = 0
      segment_duration = total_duration / 6  # Divide into 6 segments

      # Alternate between video and image clips with transitions
      for i in range(6):
          if i % 2 == 0:
              clip = video_clips[i//2].subclip(0, segment_duration)
          else:
              clip = image_clips[i//2].set_duration(segment_duration)
          
          # Add fade effects
          clip = clip.fadein(0.5).fadeout(0.5)
          
          # Position clip
          clip = clip.set_start(current_time).set_position('center')
          clips.append(clip)
          current_time += segment_duration - 0.5  # Overlap for smooth transition

      # Create text clips for script
      script_lines = "#{video.script}".split('\\n')
      for i, line in enumerate(script_lines):
          if line.strip():
              start_time = i * (total_duration / len(script_lines))
              duration = total_duration / len(script_lines)
              text_clip = create_text_clip(line, duration)
              text_clip = text_clip.set_start(start_time).set_position('center')
              clips.append(text_clip)

      # Add hashtags at the end
      hashtags = create_text_clip("#부정선거 #팩트체크 #정치", 3, font_size=40)
      hashtags = hashtags.set_start(total_duration-3).set_position(('center', 'bottom'))
      clips.append(hashtags)

      # Compose final video
      final = CompositeVideoClip(clips, size=(1080, 1920))
      final = final.set_audio(audio)

      # Export with high quality
      final.write_videofile(
          "public/videos/#{video.id}_final.mp4",
          fps=30,
          codec='libx264',
          audio_codec='aac',
          preset='slow',
          bitrate='4000k'
      )

      # Generate thumbnail
      final.save_frame(
          "public/thumbnails/#{video.id}_thumb.png",
          t=total_duration/2
      )
    PYTHON

    File.write('tmp/generate_video.py', python_script)
    system('python tmp/generate_video.py')
  end

  def cleanup_temp_files
    Dir.glob('tmp/audio*.mp3').each { |f| File.delete(f) if File.exist?(f) }
    Dir.glob('tmp/stock_video_*.mp4').each { |f| File.delete(f) if File.exist?(f) }
    Dir.glob('tmp/background_*.jpg').each { |f| File.delete(f) if File.exist?(f) }
    File.delete('tmp/generate_video.py') if File.exist?('tmp/generate_video.py')
  end
end 