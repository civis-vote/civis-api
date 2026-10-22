require 'rails_helper'

RSpec.describe VoiceMessageTranscriptionProcessor do
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
                                 visibility: :shared, response_status: :acceptable,
                                 transcription_status: :pending)
  end

  def attach_voice(filename)
    response.voice_messages.attach(io: StringIO.new('fake audio'), filename: filename,
                                   content_type: 'audio/mpeg')
    response.save!
    response.voice_messages.attachments.last
  end

  def write_voice_entries(entries)
    response.update_columns(voice_responses: entries)
  end

  def entry_for(attachment, question_id:, transcription: nil)
    { 'question_id' => question_id, 'attachment_id' => attachment.id, 'transcription' => transcription }
  end

  let(:success_result) do
    { success: true, transcription: 'refined transcription', detected_language: 'english',
      confidence: 0.9, is_proper_transcription: true, errors: [] }
  end

  let(:failure_result) do
    { success: false, transcription: nil, detected_language: nil, confidence: nil,
      is_proper_transcription: false, errors: ['Transcription failed'] }
  end

  before do
    allow_any_instance_of(VoiceMessageTranscriptionService).to receive(:call).and_return(service_result)
  end

  describe 'successful transcription' do
    let(:service_result) { success_result }
    let(:attachment) { attach_voice('a.mp3') }

    before { write_voice_entries([entry_for(attachment, question_id: 1)]) }

    it 'marks the response as completed when all entries are transcribed' do
      described_class.new(response.id, attachment.id).call

      expect(response.reload.transcription_status).to eq('completed')
    end

    it 'stores the transcription on the voice entry' do
      described_class.new(response.id, attachment.id).call

      entry = response.reload.voice_responses.first
      expect(entry['transcription']).to eq('refined transcription')
      expect(entry['detected_language']).to eq('english')
      expect(entry['confidence']).to eq(0.9)
    end

    it 'merges the transcription into answers' do
      described_class.new(response.id, attachment.id).call

      answer = response.reload.answers.find { |ans| ans['question_id'].to_s == '1' }
      expect(answer['answer']).to eq('refined transcription')
    end

    it 'preserves an existing text answer for the same question' do
      response.update_columns(answers: [{ 'question_id' => '1', 'answer' => 'typed answer' }])

      described_class.new(response.id, attachment.id).call

      answer = response.reload.answers.find { |ans| ans['question_id'].to_s == '1' }
      expect(answer['answer']).to eq('typed answer')
    end

    context 'with a second untranscribed voice entry' do
      let(:other_attachment) { attach_voice('b.mp3') }

      before do
        write_voice_entries([entry_for(attachment, question_id: 1),
                             entry_for(other_attachment, question_id: 2)])
      end

      it 'keeps the response as pending until all entries are transcribed' do
        described_class.new(response.id, attachment.id).call

        expect(response.reload.transcription_status).to eq('pending')
      end
    end
  end

  describe 'failed transcription' do
    let(:service_result) { failure_result }
    let(:attachment) { attach_voice('a.mp3') }

    before { write_voice_entries([entry_for(attachment, question_id: 1)]) }

    it 'marks the response as failed when no other entries remain' do
      described_class.new(response.id, attachment.id).call

      expect(response.reload.transcription_status).to eq('failed')
      expect(response.reload.transcription_errors).to eq(['Transcription failed'])
    end

    context 'with a second untranscribed voice entry' do
      let(:other_attachment) { attach_voice('b.mp3') }

      before do
        write_voice_entries([entry_for(attachment, question_id: 1),
                             entry_for(other_attachment, question_id: 2)])
      end

      it 'keeps the response as pending while siblings are still in flight' do
        described_class.new(response.id, attachment.id).call

        expect(response.reload.transcription_status).to eq('pending')
      end
    end
  end
end
