require 'rails_helper'

RSpec.describe Wordindex, type: :model do
  let(:admin) { create(:user, role: :admin) }

  before { Current.user = admin }
  after { Current.reset }

  it 'needs a word' do
    expect(Wordindex.new).not_to be_valid
  end

  it 'stamps the creator from Current.user' do
    wordindex = Wordindex.create!(word: 'Federalism', description: 'Division of powers')

    expect(wordindex.created_by).to eq(admin)
  end

  describe 'scopes' do
    it 'searches words and descriptions' do
      wordindex = Wordindex.create!(word: 'Quorum', description: 'Minimum members needed')

      expect(Wordindex.search('quorum')).to include(wordindex)
      expect(Wordindex.search('minimum')).to include(wordindex)
    end

    it 'orders alphabetically' do
      Wordindex.create!(word: 'Zebra')
      first = Wordindex.create!(word: 'Apple')

      expect(Wordindex.alphabetical.first).to eq(first)
    end
  end
end
