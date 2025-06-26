# FraudElection Tutorial 🎓

A step-by-step guide to get started with FraudElection.

## First Steps 👣

### 1. Installation (5 minutes)

```bash
# Clone the repository
git clone https://github.com/yourusername/FraudElection.git
cd FraudElection

# Install dependencies
bundle install
yarn install

# Set up database
rails db:setup
```

### 2. Configuration (10 minutes)

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Get your API keys:
   - [Korean Legislative API](https://open.assembly.go.kr)
   - [US Congress API](https://api.congress.gov)
   - [YouTube API](https://console.developers.google.com)

3. Update `.env` with your keys

### 3. Start Services (5 minutes)

```bash
# Start Redis
redis-server

# Start Sidekiq
bundle exec sidekiq

# Start Rails server
./bin/dev
```

## Basic Usage 🚀

### 1. Dashboard Overview (5 minutes)

1. Open `http://localhost:3000`
2. Familiarize yourself with:
   - Pipeline Progress section
   - News Articles section
   - Legislation section
   - Video Queue section

### 2. First Data Collection (10 minutes)

1. Click "데이터 수집" button
2. Watch the progress bars
3. Review collected data in respective sections
4. Check for any errors in the logs

### 3. Content Generation (15 minutes)

1. Select interesting news articles
2. Click "Generate Script"
3. Review generated script
4. Approve or edit as needed
5. Monitor video production progress

### 4. Video Publishing (10 minutes)

1. Preview generated video
2. Review metadata (title, description)
3. Approve for upload
4. Monitor upload progress
5. Check YouTube channel

## Advanced Features 🔥

### 1. Custom Scheduling

Edit `config/schedule.yml`:
```yaml
crawl_news_job:
  cron: "*/30 * * * *"  # Customize frequency
```

### 2. Content Filtering

Update `config/content_filters.yml`:
```yaml
keywords:
  include:
    - election fraud
    - voting irregularities
  exclude:
    - unrelated terms
```

### 3. Style Customization

Modify `app/assets/stylesheets/application.css`:
```css
/* Customize your dashboard */
.progress-bar {
  /* Your styles */
}
```

## Best Practices 💡

1. **Content Quality**
   - Review scripts before production
   - Maintain neutral tone
   - Include sources

2. **Resource Management**
   - Monitor disk space
   - Watch API quotas
   - Regular log rotation

3. **Maintenance**
   - Daily backup
   - Weekly system updates
   - Monthly performance review

## Next Steps 🎯

1. **Customize Content**
   - Add new news sources
   - Adjust analysis parameters
   - Fine-tune video style

2. **Scale Up**
   - Increase crawling frequency
   - Add more languages
   - Expand topic coverage

3. **Integrate**
   - Add social media sharing
   - Implement analytics
   - Set up monitoring

## Troubleshooting Tips 🔧

### Common Issues

1. **Slow Data Collection**
   - Check internet connection
   - Verify API status
   - Review rate limits

2. **Failed Video Generation**
   - Check disk space
   - Verify FFmpeg installation
   - Check error logs

3. **Upload Issues**
   - Verify YouTube credentials
   - Check quota usage
   - Review video format

## Getting Help 🆘

- Check [Documentation](/docs)
- Visit [GitHub Issues](https://github.com/yourusername/FraudElection/issues)
- Email: support@fraudelection.com

## Quick Reference 📝

### Useful Commands

```bash
# Health check
rails health:check

# Clear jobs
rake sidekiq:clear

# System status
rails system:status

# Logs
tail -f log/development.log
```

### Key Files

- `config/schedule.yml`: Job timing
- `config/sidekiq.yml`: Worker config
- `.env`: Environment variables
- `log/sidekiq.log`: Job logs 