class SearchAnalytics
    def self.most_common_queries(limit: 10)
      Search.group(:content).order('count_id DESC').limit(limit).count('id')
    end
  
    # Add more methods as needed for different types of analytics
  end