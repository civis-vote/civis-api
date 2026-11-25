require 'rails_helper'

RSpec.describe ThemeMap, type: :model do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end
  let(:organisation) { Organisation.create!(name: "Org #{SecureRandom.hex(4)}", created_by: user) }
  let(:theme_a) { Theme.create!(name: "Theme A #{SecureRandom.hex(4)}") }
  let(:theme_b) { Theme.create!(name: "Theme B #{SecureRandom.hex(4)}") }

  before { Current.user = user }
  after { Current.reset }

  def create_consultation
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list,
                         status: :published, visibility: :public_consultation, published_at: 5.days.ago)
  end

  describe 'associations' do
    it 'belongs to a theme and a polymorphic mappable' do
      map = described_class.create!(theme: theme_a, mappable: department)

      expect(map.theme).to eq(theme_a)
      expect(map.mappable).to eq(department)
    end
  end

  describe 'uniqueness' do
    it 'rejects a duplicate theme for the same record' do
      described_class.create!(theme: theme_a, mappable: department)

      expect do
        described_class.create!(theme: theme_a, mappable: department)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows the same theme on different records' do
      described_class.create!(theme: theme_a, mappable: department)
      other = Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :state,
                                 department_contacts_attributes: [{ contact_type: :primary, email: 'dept2@test.com' }])

      expect { described_class.create!(theme: theme_a, mappable: other) }.not_to raise_error
    end
  end

  describe 'Department themes' do
    it 'holds several themes through theme_maps' do
      department.theme_maps.create!(theme: theme_a)
      department.theme_maps.create!(theme: theme_b)

      expect(department.themes).to contain_exactly(theme_a, theme_b)
      expect(department.theme_names).to include(theme_a.name, theme_b.name)
    end
  end

  describe 'Organisation themes' do
    it 'holds several themes through theme_maps' do
      organisation.theme_maps.create!(theme: theme_a)
      organisation.theme_maps.create!(theme: theme_b)

      expect(organisation.themes).to contain_exactly(theme_a, theme_b)
      expect(organisation.theme_names).to include(theme_a.name, theme_b.name)
    end
  end

  describe 'Consultation themes' do
    let(:consultation) { create_consultation }

    it 'holds several themes through theme_maps' do
      consultation.theme_maps.create!(theme: theme_a)
      consultation.theme_maps.create!(theme: theme_b)

      expect(consultation.themes).to contain_exactly(theme_a, theme_b)
      expect(consultation.theme_ids).to contain_exactly(theme_a.id, theme_b.id)
      expect(consultation.theme_names).to include(theme_a.name, theme_b.name)
    end

    it 'replaces themes via theme_ids=' do
      consultation.theme_maps.create!(theme: theme_a)

      consultation.theme_ids = [theme_b.id]

      expect(consultation.reload.themes).to contain_exactly(theme_b)
    end

    it 'destroys theme_maps with the consultation' do
      consultation.theme_maps.create!(theme: theme_a)

      expect { consultation.destroy }.to change(ThemeMap, :count).by(-1)
    end

    describe '.theme_filter' do
      let!(:with_theme_a) do
        c = create_consultation
        c.theme_maps.create!(theme: theme_a)
        c
      end
      let!(:with_theme_b) do
        c = create_consultation
        c.theme_maps.create!(theme: theme_b)
        c
      end
      let!(:with_both) do
        c = create_consultation
        c.theme_maps.create!(theme: theme_a)
        c.theme_maps.create!(theme: theme_b)
        c
      end
      let!(:without_themes) { create_consultation }

      it 'returns consultations matching any of the given theme ids' do
        result = Consultation.theme_filter([theme_a.id, theme_b.id])

        expect(result).to include(with_theme_a, with_theme_b, with_both)
        expect(result).not_to include(without_themes)
      end

      it 'does not duplicate a consultation matching multiple filter themes' do
        result = Consultation.theme_filter([theme_a.id, theme_b.id])

        expect(result.where(id: with_both.id).count).to eq(1)
      end

      it 'returns all consultations when no theme ids are given' do
        expect(Consultation.theme_filter(nil)).to include(with_theme_a, without_themes)
      end
    end
  end
end
