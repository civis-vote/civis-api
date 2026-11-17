# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogCategory, type: :model do
  it 'is valid from the fabricator' do
    record = Fabricate(:blog_category)
    expect(record).to be_valid
    expect(record.persisted?).to be true
  end

  it 'requires a name' do
    record = Fabricate.build(:blog_category, name: nil)
    expect(record).not_to be_valid
    expect(record.errors[:name]).to be_present
  end
end
