require 'rails_helper'

RSpec.describe Search, type: :model do
    it 'is valid with valid attributes' do
      search = Search.new(content: 'Who am I')
      expect(search).to be_valid
    end
end
