require 'httparty'
require 'date'

class LegislationAnalyzer
  KOREA_API = 'http://apis.data.go.kr/9710000/BillInfoService2/getBillList'
  US_API = 'https://api.congress.gov/v1/bill'

  IDEOLOGY_KEYWORDS = {
    # Democratic/Liberal keywords (positive score means more authoritarian)
    'regulation' => 10, 'regulate' => 10,
    'nationalization' => 20, 'nationalize' => 20,
    'surveillance' => 15, 'monitor' => 15,
    'control' => 10, 'restrict' => 10,
    'government' => 5, 'authority' => 5,
    'mandate' => 10, 'require' => 5,
    'tax' => 8, 'taxation' => 8,
    'public' => 5, 'social' => 5,
    '규제' => 10, '통제' => 15,
    '감시' => 15, '제한' => 10,
    '의무화' => 10, '강제' => 15,
    '국유화' => 20, '공영화' => 15,

    # Republican/Conservative keywords (negative score means more libertarian)
    'freedom' => -10, 'liberty' => -10,
    'deregulation' => -15, 'privatization' => -20,
    'market' => -5, 'private' => -5,
    'choice' => -8, 'voluntary' => -10,
    'individual' => -5, 'personal' => -5,
    'free market' => -15, 'competition' => -8,
    '자유' => -10, '시장' => -8,
    '민영화' => -15, '개인' => -10,
    '자율' => -10, '선택' => -8,
    '규제완화' => -15, '경쟁' => -8
  }

  def analyze
    start_date = 5.years.ago.to_date
    end_date = 2.years.from_now.to_date
    
    legislations = crawl_korea(start_date, end_date) + crawl_us(start_date, end_date)
    legislations.each do |leg|
      next if Legislation.exists?(name: leg[:name])
      
      Legislation.create!(
        name: leg[:name],
        purpose: leg[:purpose],
        summary: leg[:summary],
        ideology_score: calculate_ideology_score(leg[:summary], leg[:purpose]),
        sponsors: leg[:sponsors],
        status: leg[:status],
        proposed_date: leg[:proposed_date],
        approved_date: leg[:approved_date],
        enacted_date: leg[:enacted_date]
      )
    end
  rescue StandardError => e
    Rails.logger.error("Legislation analysis failed: #{e.message}")
  end

  private

  def crawl_korea(start_date, end_date)
    response = HTTParty.get(KOREA_API, query: {
      ServiceKey: ENV['KOREA_API_KEY'],
      Type: 'json',
      pIndex: 1,
      pSize: 100,
      proposerStartDate: start_date.strftime('%Y%m%d'),
      proposerEndDate: end_date.strftime('%Y%m%d')
    })

    return [] unless response.success?

    data = JSON.parse(response.body)
    data['items'].map do |item|
      next unless item['billName'].match?(/선거|투표|정당|민주|부정|감시/i)
      
      {
        name: item['billName'],
        purpose: item['billPurpose'],
        summary: item['billSummary'],
        sponsors: item['proposer'],
        status: item['procStageCd'],
        proposed_date: Date.parse(item['proposeDt']),
        approved_date: item['passDate'].present? ? Date.parse(item['passDate']) : nil,
        enacted_date: item['enactDate'].present? ? Date.parse(item['enactDate']) : nil
      }
    end.compact
  rescue StandardError => e
    Rails.logger.error("Korea API error: #{e.message}")
    []
  end

  def crawl_us(start_date, end_date)
    response = HTTParty.get(US_API, query: {
      api_key: ENV['US_CONGRESS_API_KEY'],
      format: 'json',
      limit: 100,
      fromDateTime: start_date.to_time.iso8601,
      toDateTime: end_date.to_time.iso8601
    })

    return [] unless response.success?

    data = JSON.parse(response.body)
    data['bills'].map do |bill|
      next unless bill['title'].match?(/election|vote|ballot|democracy|fraud|surveillance/i)
      
      {
        name: bill['number'],
        purpose: bill['title'],
        summary: bill['summary'],
        sponsors: bill['sponsor']['name'],
        status: bill['status'],
        proposed_date: Date.parse(bill['introducedDate']),
        approved_date: bill['passedDate'].present? ? Date.parse(bill['passedDate']) : nil,
        enacted_date: bill['enactedDate'].present? ? Date.parse(bill['enactedDate']) : nil
      }
    end.compact
  rescue StandardError => e
    Rails.logger.error("US API error: #{e.message}")
    []
  end

  def calculate_ideology_score(summary, purpose)
    return 50 unless summary.present? || purpose.present?

    score = 50 # Start from neutral
    text = "#{summary} #{purpose}".downcase

    # Calculate base score from keywords
    IDEOLOGY_KEYWORDS.each do |word, value|
      count = text.scan(/#{word}/i).size
      score += value * count if count > 0
    end

    # Analyze sentence structure for additional context
    score += analyze_sentence_structure(text)

    # Normalize score between 0 and 100
    [[score, 0].max, 100].min
  end

  def analyze_sentence_structure(text)
    score = 0
    
    # Analyze mandatory language
    score += 5 if text.match?(/must|shall|required|mandatory|필수|의무|해야/i)
    score -= 5 if text.match?(/may|optional|voluntary|선택|자율/i)
    
    # Analyze enforcement language
    score += 8 if text.match?(/enforce|penalty|fine|punishment|처벌|벌금|강제/i)
    score -= 3 if text.match?(/incentive|encourage|promote|장려|촉진/i)
    
    # Analyze scope
    score += 10 if text.match?(/nationwide|universal|전국|보편/i)
    score -= 5 if text.match?(/local|state|regional|지역|주/i)
    
    score
  end
end 