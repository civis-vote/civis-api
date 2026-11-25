require 'rails_helper'

RSpec.describe ImportConsultationResponse do
  after { Current.reset }

  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end
  let(:response_round) { consultation.response_rounds.order(:created_at).last }
  let(:admin) do
    User.create!(first_name: 'Admin', last_name: 'User', email: "admin-#{SecureRandom.hex(4)}@test.com",
                 password: 'Password@123', role: :admin, confirmed_at: Time.current)
  end

  def file_import_for(csv_content)
    Struct.new(:id, :import_file, :added_by).new(1, Struct.new(:download).new(csv_content), admin)
  end

  def build_csv(rows)
    headers = %w[import_key consultation_id first_name last_name email phone_number responded_at
                 response_language organisation_id visibility satisfaction_rating response_text]
    CSV.generate do |csv|
      csv << headers
      rows.each { |row| csv << headers.map { |header| row[header] } }
    end
  end

  def row_attrs(overrides = {})
    {
      'import_key' => 'key-1',
      'consultation_id' => consultation.id.to_s,
      'first_name' => 'Jane',
      'last_name' => 'Doe',
      'email' => nil,
      'phone_number' => '9812345678',
      'responded_at' => '11/11/2026',
      'response_language' => 'English',
      'organisation_id' => nil,
      'visibility' => 'anonymous',
      'satisfaction_rating' => 'satisfied',
      'response_text' => 'My response'
    }.merge(overrides)
  end

  def run_import(rows)
    importer = described_class.new(file_import: file_import_for(build_csv(rows)))
    importer.run!
    importer
  end

  describe '#run!' do
    context 'when a phone-only user with no email exists' do
      let!(:phone_only_user) do
        User.create!(first_name: 'Phone', last_name: 'Only', email: nil,
                     phone_number: '+918699901987', role: :citizen)
      end

      it 'does not link blank-email rows to the NULL-email user' do
        importer = run_import([row_attrs, row_attrs('import_key' => 'key-2', 'phone_number' => '9812345679')])

        expect(importer.invalid_rows).to be_empty
        responses = ConsultationResponse.where(consultation: consultation)
        expect(responses.count).to eq(2)
        expect(responses.pluck(:user_id).uniq).to eq([nil])
      end

      it 'stores the phone number normalized with country code and exposes it' do
        run_import([row_attrs])

        response = ConsultationResponse.find_by(consultation: consultation)
        expect(response[:phone_number]).to eq(919_812_345_678)
        expect(response.phone_number).to eq('+919812345678')
      end
    end

    context 'when the phone number belongs to an existing user' do
      let!(:existing_user) do
        User.create!(first_name: 'Existing', last_name: 'User',
                     email: "existing-#{SecureRandom.hex(4)}@test.com",
                     password: 'Password@123', phone_number: '+919812345678', role: :citizen)
      end

      it 'links the response to that user' do
        importer = run_import([row_attrs])

        expect(importer.invalid_rows).to be_empty
        expect(ConsultationResponse.find_by(consultation: consultation).user_id).to eq(existing_user.id)
      end
    end

    context 'when the email belongs to an existing user' do
      let!(:existing_user) do
        User.create!(first_name: 'Existing', last_name: 'User',
                     email: "existing-#{SecureRandom.hex(4)}@test.com",
                     password: 'Password@123', role: :citizen)
      end

      it 'links the response by email' do
        importer = run_import([row_attrs('email' => existing_user.email)])

        expect(importer.invalid_rows).to be_empty
        expect(ConsultationResponse.find_by(consultation: consultation).user_id).to eq(existing_user.id)
      end
    end

    context 'when the matched user has already responded in the same round' do
      let!(:existing_user) do
        User.create!(first_name: 'Existing', last_name: 'User',
                     email: "existing-#{SecureRandom.hex(4)}@test.com",
                     password: 'Password@123', role: :citizen)
      end

      before do
        ConsultationResponse.create!(user: existing_user, consultation: consultation,
                                     response_round: response_round, visibility: :anonymous)
      end

      it 'reports the row as a duplicate response' do
        importer = run_import([row_attrs('email' => existing_user.email, 'phone_number' => nil)])

        expect(importer.invalid_rows.size).to eq(1)
        expect(importer.invalid_rows.first.line_number).to eq(2)
        expect(importer.invalid_rows.first.errors).to include('User has already submitted a response for this round')
      end

      it 'imports nothing when any row fails (all-or-nothing)' do
        importer = run_import([row_attrs('email' => existing_user.email, 'phone_number' => nil),
                               row_attrs('import_key' => 'key-2', 'phone_number' => '9812345679')])

        expect(importer.invalid_rows.size).to eq(1)
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(1)
      end
    end

    context 'when a row has malformed data' do
      it 'reports the error with the row line number and imports nothing' do
        importer = run_import([row_attrs('responded_at' => 'not-a-date'),
                               row_attrs('import_key' => 'key-2', 'phone_number' => '9812345679')])

        expect(importer.invalid_rows.size).to eq(1)
        expect(importer.invalid_rows.first.line_number).to eq(2)
        expect(importer.invalid_rows.first.errors).to be_present
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(0)
      end
    end

    context 'when a response for the same person already exists in the round' do
      it 'reports the row instead of creating a duplicate' do
        run_import([row_attrs])
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(1)

        importer = run_import([row_attrs])

        expect(importer.invalid_rows.size).to eq(1)
        expect(importer.invalid_rows.first.errors).to include('Response already submitted for this round')
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(1)
      end

      it 'reports a repeated row within the same file' do
        importer = run_import([row_attrs, row_attrs])

        expect(importer.invalid_rows.size).to eq(1)
        expect(importer.invalid_rows.first.line_number).to eq(3)
        expect(importer.invalid_rows.first.errors).to include('Response already submitted for this round')
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(0)
      end

      it 'imports all rows that share an import_key but differ by phone' do
        importer = run_import([row_attrs, row_attrs('phone_number' => '9812345679')])

        expect(importer.invalid_rows).to be_empty
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(2)
      end
    end

    context 'with a file shaped like the WhatsApp export' do
      before { Current.user = admin }

      let!(:long_text_question) do
        Question.create!(response_round: response_round, question_text: 'Your thoughts?',
                         question_type: :long_text, is_optional: true)
      end
      let!(:checkbox_question) do
        Question.create!(response_round: response_round, question_text: 'Pick topics',
                         question_type: :checkbox, is_optional: true,
                         sub_questions_attributes: [{ question_text: 'Option A' }, { question_text: 'Option B' }])
      end
      let!(:organisation) { Fabricate(:organisation, created_by_id: admin.id) }

      def whatsapp_csv
        File.read(Rails.root.join('spec/fixtures/files/import_consultation_response_whatsapp.csv'))
            .gsub('CONSULTATION_ID', consultation.id.to_s)
            .gsub('QUESTION_LONG', long_text_question.id.to_s)
            .gsub('QUESTION_CHECK', checkbox_question.id.to_s)
            .gsub('ORGANISATION_ID', organisation.id.to_s)
      end

      def run_whatsapp_import
        described_class.new(file_import: file_import_for(whatsapp_csv)).tap(&:run!)
      end

      it 'imports every row, parses answers, and normalizes phones' do
        importer = run_whatsapp_import

        expect(importer.invalid_rows).to be_empty
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(3)

        response = ConsultationResponse.find_by(phone_number: 919920668374)
        answers = JSON.parse(response.answers.to_json)
        expect(answers).to include('question_id' => long_text_question.id.to_s, 'answer' => 'Marriage')
        expect(response[:phone_number]).to eq(919920668374)
      end

      it 'maps multi-option checkbox cells to sub-question ids' do
        run_whatsapp_import

        response = ConsultationResponse.find_by(phone_number: 919833326699)
        answers = JSON.parse(response.answers.to_json)
        option_ids = checkbox_question.sub_questions.pluck(:id).map(&:to_s)
        checkbox_answer = answers.find { |a| a['question_id'] == checkbox_question.id.to_s }
        expect(checkbox_answer['answer']).to match_array(option_ids)
      end

      it 'reports every row on re-import' do
        run_whatsapp_import
        importer = run_whatsapp_import

        expect(importer.invalid_rows.size).to eq(3)
        expect(ConsultationResponse.where(consultation: consultation).count).to eq(3)
      end
    end
  end
end
