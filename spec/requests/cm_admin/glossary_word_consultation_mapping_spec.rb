require "rails_helper"

RSpec.describe "Glossary consultation word admin", type: :request do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end
  let!(:mappings) do
    %w[Federalism Quorum].map do |word|
      wordindex = create(:wordindex, word:)
      GlossaryWordConsultationMapping.create!(consultation:, glossary: wordindex)
    end
  end
  let(:mapping) { mappings.first }

  before { cm_admin_sign_in }

  describe "index" do
    it "lists glossary consultation words" do
      expect(cm_admin_index(GlossaryWordConsultationMapping)).to list_records(*mappings)
    end
  end

  it "shows a glossary consultation word" do
    expect(cm_admin_show(mapping)).to have_field(:glossary_word).with_value(mapping.glossary.word)
  end

  # The form only declares consultation_id, so a mapping created through it has no word
  # and fails the glossary presence validation. Mappings are otherwise managed elsewhere.
  it "cannot create a mapping without a word through the form" do
    expect(cm_admin_create(GlossaryWordConsultationMapping, consultation_id: consultation.id))
      .to have_validation_error(:glossary)
  end

  it "edits a glossary consultation word" do
    other = Consultation.create!(title: "Other #{SecureRandom.hex(4)}", department: department,
                                 response_deadline: 10.days.from_now, question_flow: :question_list)

    expect(cm_admin_update(mapping, consultation_id: other.id)).to succeed
    expect(mapping.reload.consultation).to eq(other)
  end
end
