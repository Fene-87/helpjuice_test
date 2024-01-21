require 'rails_helper'

RSpec.describe SearchesController, type: :controller do
  describe 'POST #create' do
    let(:session_id) { '1234' }

    context 'with valid parameters' do
      it 'creates a new Search record' do
        expect {
          post :create, params: { search: { content: 'New search' } }
        }.to change(Search, :count).by(1)
      end

      it 'responds with success status' do
        post :create, params: { search: { content: 'New search' } }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when a search query is followed immediately by another' do
      it 'updates the existing Search record instead of creating a new one' do
        post :create, params: { search: { content: 'Why are you here' }}, session: { session_id: session_id }
        expect {
          post :create, params: { search: { content: 'Ruby on Rails' }, session_id: session_id }
        }.to change(Search, :count).by(0)
        expect(JSON.parse(response.body)['query']).to eq('Ruby on Rails')
      end
    end
  end

  describe 'GET #suggestions' do
    before do
      Search.create(content: 'Who are you?')
      Search.create(content: 'Why are you here?')
      Search.create(content: 'Where are you going?')
    end

    it 'returns relevant search suggestions' do
      get :suggestions, params: { query: 'Who' }
      expect(response).to have_http_status(:success)
      suggestions = JSON.parse(response.body)['suggestions']
      suggestions.each do |suggestion|
        expect(suggestion).to include('Who')
        expect(suggestion).not_to include('Where')
      end
    end
  end

  describe 'debounce_search method' do
    let(:session_id) { 'test_session_123' }
  
    it 'updates the last search if within the debounce time frame' do
      initial_search = Search.create(content: 'Ruby', user_session: session_id, created_at: 10.seconds.ago)
      controller.send(:debounce_search, 'Ruby on Rails', session_id)
      initial_search.reload
  
      expect(initial_search.content).to eq('Ruby on Rails')
    end
  end
end