require 'rails_helper'

RSpec.describe CaseStudy, type: :model do
  let(:admin) { create(:user, role: :admin) }

  before { Current.user = admin }
  after { Current.reset }

  it 'needs a name' do
    expect(CaseStudy.new).not_to be_valid
  end

  it 'stamps the creator from Current.user' do
    case_study = CaseStudy.create!(name: 'Solar rooftops', ministry_name: 'MNRE',
                                   case_study_type: :government, url: 'https://example.com')

    expect(case_study.created_by).to eq(admin)
  end

  it 'only accepts known case study types' do
    expect { CaseStudy.new(case_study_type: 'unknown') }.to raise_error(ArgumentError)
  end

  describe '.search' do
    it 'finds case studies by name or ministry' do
      case_study = CaseStudy.create!(name: 'Waste management in Pune', ministry_name: 'MoHUA',
                                     case_study_type: :government, url: 'https://example.com')

      expect(CaseStudy.search('pune')).to include(case_study)
      expect(CaseStudy.search('mohua')).to include(case_study)
      expect(CaseStudy.search('nothing-matches-this')).to be_empty
    end
  end
end
