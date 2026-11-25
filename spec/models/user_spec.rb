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
                                        response_deadline: 10.days.from_now,
                                        question_flow: :question_list, status: :published,
                                        visibility: :public_consultation, published_at: 5.days.ago)
    consultation.theme_maps.create!(theme: theme) if theme
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
      user.user_preferences.create!(preferable: area_of_impact)
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

  describe 'phone number' do
    it 'normalizes a 10-digit number with the default country code' do
      phone_user = described_class.create!(phone_number: '9876501234', role: :citizen)
      expect(phone_user.phone_number).to eq('+919876501234')
    end

    it 'keeps an already normalized number' do
      phone_user = described_class.create!(phone_number: '+919876501234', role: :citizen)
      expect(phone_user.phone_number).to eq('+919876501234')
    end

    it 'does not allow duplicate phone numbers' do
      described_class.create!(phone_number: '+919876501234', role: :citizen)
      duplicate = described_class.new(phone_number: '9876501234', role: :citizen)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'contact verification reset' do
    it 'clears confirmed_at when the email changes' do
      user.update!(email: 'changed@example.com')
      expect(user.confirmed_at).to be_nil
    end

    it 'clears phone_verified_at when the phone number changes' do
      user.update_columns(phone_verified_at: Time.current)
      user.update!(phone_number: '+919123456780')
      expect(user.phone_verified_at).to be_nil
    end
  end

  describe 'contact details validation' do
    it 'is invalid without email and phone number' do
      record = described_class.new(first_name: 'No', last_name: 'Contact', role: :citizen)
      expect(record).not_to be_valid
    end

    it 'is valid with only a phone number and no email' do
      record = described_class.new(phone_number: '+919876501234', role: :citizen)
      expect(record).to be_valid
    end
  end

  describe '.find_for_login' do
    let!(:phone_user) { described_class.create!(phone_number: '+919876501234', role: :citizen) }

    it 'finds by normalized phone number' do
      expect(described_class.find_for_login(phone_number: '9876501234')).to eq(phone_user)
    end

    it 'finds by email' do
      expect(described_class.find_for_login(email: user.email)).to eq(user)
    end
  end

  describe '#verify_otp' do
    it 'sets confirmed_at for email OTPs' do
      unconfirmed = described_class.create!(email: Faker::Internet.unique.email, role: :citizen)
      otp = unconfirmed.create_otp_request(delivery_channel: :email)
      expect(unconfirmed.verify_otp(otp.otp.to_s)).to be true
      expect(unconfirmed.reload.confirmed_at).to be_present
    end

    it 'sets phone_verified_at for phone OTPs' do
      phone_user = described_class.create!(phone_number: '+919876501234', role: :citizen)
      otp = phone_user.create_otp_request(delivery_channel: :phone)
      expect(phone_user.verify_otp(otp.otp.to_s)).to be true
      expect(phone_user.reload.phone_verified_at).to be_present
      expect(phone_user.confirmed_at).to be_nil
    end
  end
end
