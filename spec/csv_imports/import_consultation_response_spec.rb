require 'rails_helper'

RSpec.describe ImportConsultationResponse do
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
    OpenStruct.new(import_file: OpenStruct.new(download: csv_content), added_by: admin)
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
        expect(response[:phone_number]).to eq(919812345678)
        expect(response.phone_number).to eq(919812345678)
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
  end
end
