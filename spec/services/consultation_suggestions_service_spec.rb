require 'rails_helper'

RSpec.describe ConsultationSuggestionsService do
  let(:department_a) do
    Department.create!(name: "Dept A #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept_a@test.com' }])
  end
  let(:department_b) do
    Department.create!(name: "Dept B #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept_b@test.com' }])
  end
  let(:theme_a) { Theme.create!(name: "Theme A #{SecureRandom.hex(4)}") }
  let(:theme_b) { Theme.create!(name: "Theme B #{SecureRandom.hex(4)}") }
  let(:area_of_impact_a) { Constant.create!(name: "AoI A #{SecureRandom.hex(4)}", constant_type: :area_of_impact) }
  let(:area_of_impact_b) { Constant.create!(name: "AoI B #{SecureRandom.hex(4)}", constant_type: :area_of_impact) }
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  before { Current.user = user }
  after { Current.reset }

  def create_consultation(department:, theme: nil, deadline: 10.days.from_now, featured: false,
                          area_of_impacts: [], status: :published, visibility: :public_consultation)
    consultation = Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                                        theme: theme, response_deadline: deadline, question_flow: :question_list,
                                        is_featured: featured, status: status, visibility: visibility,
                                        published_at: 5.days.ago)
    area_of_impacts.each { |aoi| consultation.constant_maps.create!(constant: aoi) }
    consultation
  end

  def create_response(consultation:, responder: user, visibility: :shared, response_status: :acceptable)
    ConsultationResponse.create!(user: responder, consultation: consultation,
                                 response_round: consultation.response_rounds.last,
                                 visibility: visibility, response_status: response_status)
  end

  def other_user
    User.create!(first_name: 'Other', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end

  describe 'content matching with a source consultation' do
    let!(:source) do
      create_consultation(department: department_a, theme: theme_a, area_of_impacts: [area_of_impact_a])
    end

    it 'ranks same-theme candidates above same-department candidates' do
      same_department = create_consultation(department: department_a, theme: theme_b)
      same_theme = create_consultation(department: department_b, theme: theme_a)

      result = described_class.new(user: user, consultation_id: source.id).call

      expect(result.index(same_theme)).to be < result.index(same_department)
    end

    it 'ranks multi-signal matches above single-signal matches' do
      multi = create_consultation(department: department_a, theme: theme_a, area_of_impacts: [area_of_impact_a])
      single = create_consultation(department: department_a, theme: theme_b)

      result = described_class.new(user: user, consultation_id: source.id).call

      expect(result.first).to eq(multi)
      expect(result.index(single)).to be > result.index(multi)
    end

    it 'boosts featured consultations' do
      featured = create_consultation(department: department_b, theme: theme_b, featured: true)
      plain = create_consultation(department: department_b, theme: theme_b,
                                  deadline: featured.response_deadline)

      result = described_class.new(user: user, consultation_id: source.id).call

      expect(result.index(featured)).to be < result.index(plain)
    end

    it 'excludes the source consultation itself' do
      create_consultation(department: department_a)

      result = described_class.new(user: user, consultation_id: source.id).call

      expect(result).not_to include(source)
    end
  end

  describe 'preference scoring' do
    it 'ranks a preferred-theme candidate above a candidate with higher history' do
      user.preferred_theme_ids = [theme_b.id]

      history_consultation = create_consultation(department: department_a, theme: theme_a)
      create_response(consultation: history_consultation)
      create_response(consultation: create_consultation(department: department_a, theme: theme_a))

      preferred = create_consultation(department: department_b, theme: theme_b)
      history_only = create_consultation(department: department_b, theme: theme_a)

      result = described_class.new(user: user).call

      expect(result.index(preferred)).to be < result.index(history_only)
    end

    it 'scores each matching preferred area of impact' do
      user.constant_maps.create!(constant: area_of_impact_a)
      user.constant_maps.create!(constant: area_of_impact_b)

      both_aois = create_consultation(department: department_a, area_of_impacts: [area_of_impact_a, area_of_impact_b])
      one_aoi = create_consultation(department: department_a, area_of_impacts: [area_of_impact_a])

      result = described_class.new(user: user).call

      expect(result.index(both_aois)).to be < result.index(one_aoi)
    end
  end

  describe 'history scoring' do
    it 'weights frequently-responded themes higher' do
      3.times { create_response(consultation: create_consultation(department: department_a, theme: theme_a)) }
      create_response(consultation: create_consultation(department: department_a, theme: theme_b))

      frequent_theme = create_consultation(department: department_b, theme: theme_a)
      rare_theme = create_consultation(department: department_b, theme: theme_b)

      result = described_class.new(user: user).call

      expect(result.index(frequent_theme)).to be < result.index(rare_theme)
    end

    it 'caps the theme history contribution at 5 points' do
      department_c = Department.create!(name: "Dept C #{SecureRandom.hex(4)}", level: :national,
                                        department_contacts_attributes: [{ contact_type: :primary, email: 'dept_c@test.com' }])
      10.times { create_response(consultation: create_consultation(department: department_a, theme: theme_a)) }

      source = create_consultation(department: department_c, theme: theme_b)
      # history only: theme_a gives min(10 * 1, 5) = 5 points, no dept history for department_b
      capped_candidate = create_consultation(department: department_b, theme: theme_a)
      # content score of 6: same theme (+3) + same department (+2) + featured (+1)
      challenger = create_consultation(department: department_c, theme: theme_b, featured: true)

      result = described_class.new(user: user, consultation_id: source.id).call

      # 10 theme-history responses would give 10 points uncapped; capped at 5 the
      # challenger's 6 content points win
      expect(result.index(challenger)).to be < result.index(capped_candidate)
    end
  end

  describe 'exclusions' do
    it 'never returns consultations the user already responded to' do
      responded = create_consultation(department: department_a)
      create_response(consultation: responded)
      open_consultation = create_consultation(department: department_a)

      result = described_class.new(user: user).call

      expect(result).to include(open_consultation)
      expect(result).not_to include(responded)
    end

    it 'never returns expired consultations' do
      expired = create_consultation(department: department_a, deadline: 1.day.ago)
      open_consultation = create_consultation(department: department_a)

      result = described_class.new(user: user).call

      expect(result).to include(open_consultation)
      expect(result).not_to include(expired)
    end

    it 'never returns private consultations' do
      private_consultation = create_consultation(department: department_a, visibility: :private_consultation)
      open_consultation = create_consultation(department: department_a)

      result = described_class.new(user: user).call

      expect(result).to include(open_consultation)
      expect(result).not_to include(private_consultation)
    end

    it 'never returns unpublished consultations' do
      submitted = create_consultation(department: department_a, status: :submitted)
      open_consultation = create_consultation(department: department_a)

      result = described_class.new(user: user).call

      expect(result).to include(open_consultation)
      expect(result).not_to include(submitted)
    end
  end

  describe 'cold start fallback' do
    it 'orders by shared, acceptable response count then earliest deadline' do
      unpopular = create_consultation(department: department_a, deadline: 3.days.from_now)
      popular = create_consultation(department: department_a, deadline: 20.days.from_now)
      mid = create_consultation(department: department_a, deadline: 10.days.from_now)

      2.times { create_response(consultation: popular, responder: other_user) }
      create_response(consultation: mid, responder: other_user)

      result = described_class.new(user: user).call

      expect(result.map(&:id)).to eq([popular.id, mid.id, unpopular.id])
    end

    it 'ignores anonymous and non-acceptable responses in the popularity count' do
      noisy = create_consultation(department: department_a, deadline: 20.days.from_now)
      quiet = create_consultation(department: department_a, deadline: 10.days.from_now)

      create_response(consultation: noisy, responder: other_user, visibility: :anonymous)
      create_response(consultation: noisy, responder: other_user, response_status: :under_review)
      create_response(consultation: quiet, responder: other_user)

      result = described_class.new(user: user).call

      expect(result.map(&:id)).to eq([quiet.id, noisy.id])
    end
  end

  describe 'behaviour without a source consultation' do
    it 'still ranks by preferences and history' do
      user.preferred_theme_ids = [theme_b.id]
      create_response(consultation: create_consultation(department: department_a, theme: theme_a))

      preferred = create_consultation(department: department_b, theme: theme_b)
      history_only = create_consultation(department: department_b, theme: theme_a)

      result = described_class.new(user: user).call

      expect(result.index(preferred)).to be < result.index(history_only)
    end

    it 'treats a nonexistent consultation_id as no source' do
      consultation = create_consultation(department: department_a)

      result = described_class.new(user: user, consultation_id: 999_999).call

      expect(result).to include(consultation)
    end
  end

  describe 'limit' do
    it 'returns at most limit results' do
      5.times { create_consultation(department: department_a) }

      expect(described_class.new(user: user).call(limit: 2).size).to eq(2)
      expect(described_class.new(user: user).call.size).to eq(3)
    end
  end
end
