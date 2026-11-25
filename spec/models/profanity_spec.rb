require 'rails_helper'

RSpec.describe Profanity, type: :model do
  let(:admin) { create(:user, role: :admin) }

  before { Current.user = admin }
  after { Current.reset }

  it 'needs a profane word' do
    expect(Profanity.new).not_to be_valid
  end

  it 'stamps the creator from Current.user' do
    profanity = Profanity.create!(profane_word: 'gosh')

    expect(profanity.created_by).to eq(admin)
  end

  describe 'scopes' do
    it 'searches by word' do
      profanity = Profanity.create!(profane_word: 'fluff')

      expect(Profanity.search_profane_word('fluff')).to include(profanity)
    end

    it 'sorts alphabetically' do
      Profanity.create!(profane_word: 'zebra')
      first = Profanity.create!(profane_word: 'apple')

      expect(Profanity.sort_records('profane_word', 'asc').first).to eq(first)
    end
  end
end
