require 'rails_helper'

RSpec.describe ConsultationResponse do
  let(:department) do
    Department.create!(name: "Dept #{SecureRandom.hex(4)}", level: :national,
                       department_contacts_attributes: [{ contact_type: :primary, email: 'dept@test.com' }])
  end
  let(:consultation) do
    Consultation.create!(title: "Consultation #{SecureRandom.hex(4)}", department: department,
                         response_deadline: 10.days.from_now, question_flow: :question_list)
  end
  let(:user) do
    User.create!(first_name: 'Test', last_name: 'User', email: Faker::Internet.unique.email,
                 password: 'Password@123', role: :citizen, confirmed_at: Time.current)
  end
  let(:response) do
    ConsultationResponse.create!(user: user, consultation: consultation,
                                 response_round: ResponseRound.create!(consultation: consultation),
                                 visibility: :shared, response_status: :acceptable)
  end

  let(:audio_file) do
    tempfile = Tempfile.new(['voice', '.mp3'])
    tempfile.write('fake audio')
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: 'voice.mp3', type: 'audio/mpeg')
  end

  describe '.response_text_filter' do
    let!(:text_response) do
      ConsultationResponse.create!(user: user, consultation: consultation,
                                   response_round: ResponseRound.create!(consultation: consultation),
                                   visibility: :shared, response_text: 'Great initiative!')
    end
    let!(:blank_response) do
      ConsultationResponse.create!(consultation: consultation,
                                   response_round: ResponseRound.create!(consultation: consultation),
                                   visibility: :shared)
    end
    let!(:whitespace_response) do
      ConsultationResponse.create!(consultation: consultation,
                                   response_round: ResponseRound.create!(consultation: consultation),
                                   visibility: :shared, response_text: '<p>&nbsp;</p>')
    end

    it 'returns only responses with non-blank response text when true' do
      result = described_class.response_text_filter(true)
      expect(result).to include(text_response)
      expect(result).not_to include(blank_response, whitespace_response)
    end

    it 'returns only responses without response text when false' do
      result = described_class.response_text_filter(false)
      expect(result).to include(blank_response, whitespace_response)
      expect(result).not_to include(text_response)
    end

    it 'returns all responses when nil' do
      result = described_class.response_text_filter(nil)
      expect(result).to include(text_response, blank_response, whitespace_response)
    end
  end

  describe '#submit_voice_responses' do
    context 'with no voice responses' do
      it 'keeps the not_available transcription status' do
        response.submit_voice_responses(nil)

        expect(response.reload.transcription_status).to eq('not_available')
      end

      it 'keeps the not_available transcription status for an empty list' do
        response.submit_voice_responses([])

        expect(response.reload.transcription_status).to eq('not_available')
      end
    end

    context 'with voice responses' do
      it 'attaches the files and marks the response as pending' do
        response.submit_voice_responses([{ question_id: 1, file: audio_file }])

        expect(response.reload.transcription_status).to eq('pending')
        expect(response.voice_messages.attachments.count).to eq(1)
      end

      it 'stores voice response entries with nil transcription' do
        response.submit_voice_responses([{ question_id: 1, file: audio_file }])

        entry = response.reload.voice_responses.first
        expect(entry['question_id']).to eq(1)
        expect(entry['attachment_id']).to eq(response.voice_messages.attachments.last.id)
        expect(entry['transcription']).to be_nil
      end
    end
  end
end
