# FraudElection Manual 📚

## Table of Contents

1. [System Overview](#system-overview)
2. [Dashboard Guide](#dashboard-guide)
3. [Content Pipeline](#content-pipeline)
4. [Configuration](#configuration)
5. [Troubleshooting](#troubleshooting)

## System Overview

FraudElection automates the process of:
- Monitoring election fraud news
- Analyzing legislation
- Generating video content
- Publishing to YouTube

### System Requirements

- CPU: 4+ cores recommended
- RAM: 8GB minimum, 16GB recommended
- Storage: 50GB+ free space
- Network: Stable internet connection
- OS: macOS, Linux, or Windows WSL2

## Dashboard Guide

### Main Interface

1. **Header Section**
   - System status indicators
   - "데이터 수집" (Data Collection) button
   - Language switcher (한국어/English)

2. **Pipeline Progress**
   - Real-time job status
   - Progress bars for each process
   - Error indicators and logs

3. **Content Management**
   - News article list
   - Legislation analysis
   - Generated scripts
   - Video production queue

### Key Actions

1. **Data Collection**
   - Click "데이터 수집" to start crawling
   - Monitor progress in real-time
   - View collected items in respective sections

2. **Content Review**
   - Review generated scripts
   - Approve/reject content
   - Edit before production

3. **Video Management**
   - Monitor video production
   - Preview before upload
   - Track YouTube metrics

## Content Pipeline

### 1. News Crawling
- Sources: Reuters, Yonhap, etc.
- Frequency: Every 30 minutes
- Filtering: AI-based relevance check

### 2. Legislation Analysis
- Sources: Korean/US legislative databases
- Analysis: Sentiment and impact
- Frequency: Daily updates

### 3. Script Generation
- AI-powered content creation
- Fact-checking integration
- Tone and style consistency

### 4. Video Production
- Automated assembly
- Voice synthesis (gTTS)
- Visual effects and transitions

### 5. YouTube Upload
- Automated publishing
- SEO optimization
- Analytics tracking

## Configuration

### Environment Variables

```bash
# API Keys
KOREA_API_KEY=xxx
US_CONGRESS_API_KEY=xxx
YOUTUBE_API_KEY=xxx

# Content Settings
MAX_VIDEO_LENGTH=60
LANGUAGE_PRIORITY=ko,en
CONTENT_FILTER_LEVEL=moderate

# System Settings
REDIS_URL=redis://localhost:6379/0
SIDEKIQ_CONCURRENCY=5
```

### Scheduling

Edit `config/schedule.yml` for job timing:

```yaml
crawl_news_job:
  cron: "*/30 * * * *"  # Every 30 minutes

crawl_legislation_job:
  cron: "0 0 * * *"     # Daily at midnight

generate_script_job:
  cron: "0 * * * *"     # Hourly

produce_video_job:
  cron: "0 */2 * * *"   # Every 2 hours

upload_video_job:
  cron: "0 */3 * * *"   # Every 3 hours
```

## Troubleshooting

### Common Issues

1. **Job Queue Stuck**
   ```bash
   # Reset Sidekiq
   bundle exec sidekiqctl quiet
   bundle exec sidekiqctl stop
   bundle exec sidekiq
   ```

2. **Video Generation Fails**
   - Check FFmpeg installation
   - Verify storage space
   - Check log files

3. **API Rate Limits**
   - Implement exponential backoff
   - Adjust scheduling
   - Use API quotas wisely

### Logging

- Application logs: `log/production.log`
- Sidekiq logs: `log/sidekiq.log`
- Error tracking: Integrated with Sentry

### Support

For additional support:
- GitHub Issues
- Email: support@fraudelection.com
- Documentation: [/docs](/docs) 