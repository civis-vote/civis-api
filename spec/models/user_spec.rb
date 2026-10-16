require 'rails_helper'

RSpec.describe User, type: :model do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:theme_a) { Theme.create!(name: "Theme A #{SecureRandom.hex(4)}") }
  let(:theme_b) { Theme.create!(name: "Theme B #{SecureRandom.hex(4)}") }
  let(:area_of_impact) { Constant.create!(name: "AoI #{SecureRandom.hex(4)}", constant_type: :area_of_impact) }
  let(:user) do
    described_class.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                            password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  before { Current.user = user }
  after { Current.reset }

  def create_consultation(theme: nil, area_of_impacts: [])
    consultation = Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                                        theme: theme, response_deadline: 10.days.from_now,
                                        question_flow: :question_list, status: :published,
                                        visibility: :public_consultation, published_at: 5.days.ago)
    area_of_impacts.each { |aoi| consultation.constant_maps.create!(constant: aoi) }
    consultation
  end

  def create_response(consultation:)
    ConsultationResponse.create!(user: user, consultation: consultation,
                                 response_round: consultation.response_rounds.last)
  end

  describe '#has_preferences?' do
    it 'is false with no preferences' do
      expect(user.has_preferences?).to be false
    end

    it 'is true with a preferred theme' do
      user.preferred_theme_ids = [theme_a.id]
      expect(user.has_preferences?).to be true
    end

    it 'is true with a preferred area of impact' do
      user.constant_maps.create!(constant: area_of_impact)
      expect(user.has_preferences?).to be true
    end
  end

  describe 'history count maps' do
    before do
      2.times { create_response(consultation: create_consultation(theme: theme_a, area_of_impacts: [area_of_impact])) }
      create_response(consultation: create_consultation(theme: theme_b))
    end

    it 'counts responses per theme' do
      expect(user.theme_response_counts).to eq(theme_a.id => 2, theme_b.id => 1)
    end

    it 'counts responses per department' do
      expect(user.department_response_counts).to eq(department.id => 3)
    end

    it 'counts responses per area of impact' do
      expect(user.area_of_impact_response_counts).to eq(area_of_impact.id => 2)
    end
  end
end
