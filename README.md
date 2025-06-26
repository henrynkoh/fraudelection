# FraudElection 🗳️

An automated system for tracking, analyzing, and reporting on election fraud news and legislation through AI-generated YouTube Shorts.

## Overview 🌐

FraudElection is a sophisticated Ruby on Rails application that automatically:
1. Crawls news sources for election fraud related content
2. Analyzes election legislation
3. Generates engaging scripts
4. Produces and uploads YouTube Shorts
5. Supports both Korean and English content

## Features ✨

- **Automated News Crawling**: Continuously monitors trusted news sources
- **Legislation Analysis**: Tracks and analyzes election-related legislation
- **AI Script Generation**: Creates engaging, factual scripts for videos
- **Automated Video Production**: Converts scripts into professional YouTube Shorts
- **Bilingual Support**: Full support for Korean and English content
- **Real-time Dashboard**: Monitor all processes through an intuitive interface
- **Scheduled Jobs**: Automated content pipeline with Sidekiq
- **Progress Tracking**: Real-time progress monitoring of all processes

## Quick Start 🚀

### Prerequisites

- Ruby 3.2.2
- Rails 8.0.2
- Redis
- Node.js & Yarn
- FFmpeg (for video processing)
- YouTube API credentials

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/FraudElection.git
cd FraudElection
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your credentials
```

4. Set up the database:
```bash
rails db:create db:migrate db:seed
```

5. Start the services:
```bash
./bin/dev                 # Development server
bundle exec sidekiq       # Background jobs
```

6. Visit `http://localhost:3000` to access the dashboard

## Architecture 🏗️

### Components

- **News Crawler**: Automated news source monitoring
- **Legislation Analyzer**: Bill tracking and analysis
- **Script Generator**: AI-powered content creation
- **Video Producer**: Automated video generation
- **YouTube Uploader**: Automated content publishing

### Job Pipeline

1. `CrawlNewsJob`: Gathers latest news (every 30 minutes)
2. `CrawlLegislationJob`: Updates legislation data (daily)
3. `GenerateScriptJob`: Creates video scripts (hourly)
4. `ProduceVideoJob`: Generates videos (every 2 hours)
5. `UploadVideoJob`: Publishes to YouTube (every 3 hours)

## Development 👩‍💻

### Running Tests

```bash
rails test                # Run all tests
rails test:system        # Run system tests
```

### Code Style

```bash
rubocop                  # Ruby style checking
yarn lint               # JavaScript style checking
```

### Adding New Features

1. Create a feature branch
2. Write tests
3. Implement the feature
4. Submit a pull request

## Production Deployment 🚀

### Using Kamal

```bash
kamal setup
kamal deploy
```

### Manual Deployment

1. Set up production environment
2. Configure secrets
3. Deploy application
4. Set up background workers

## Contributing 🤝

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

- Documentation: [/docs](/docs)
- Issues: [GitHub Issues](https://github.com/yourusername/FraudElection/issues)
- Email: support@fraudelection.com

## Acknowledgments 🙏

- [Ruby on Rails](https://rubyonrails.org/)
- [Sidekiq](https://sidekiq.org/)
- [YouTube API](https://developers.google.com/youtube)
- All contributors and supporters
