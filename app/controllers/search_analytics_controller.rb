class SearchAnalyticsController < ApplicationController
    def index
      @most_common_queries = SearchAnalytics.most_common_queries
  
      respond_to do |format|
        format.html
        format.json { render json: { common_queries: @most_common_queries } }
      end
    end
end