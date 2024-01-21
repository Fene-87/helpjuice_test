class SearchesController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def index; end
    
    def create
      search = debounce_search(search_params[:content], session[:session_id])

      if search.persisted?
        render json: { status: 'success', query: search.content }
      else
        render json: { status: 'error' }
      end
    end

    def suggestions
      query = params[:query]
        suggested_queries = Search.where('content LIKE ?', "%#{query}%")
                                 .limit(5)
                                 .pluck(:content)
    
        render json: { suggestions: suggested_queries }
    end

    private

    def search_params
      params.require(:search).permit(:content)
    end

    def debounce_search(content, session_id)
      last_search = Search.where(user_session: session_id)
                          .where('created_at >= ?', 30.seconds.ago).last

      if last_search
        last_search.update(content: content)
        last_search
      else
        Search.create(content: content, user_session: session_id)
      end
    end
end
