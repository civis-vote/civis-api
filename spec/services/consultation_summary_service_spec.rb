require 'rails_helper'

RSpec.describe ConsultationSummaryService do
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
  let!(:response) do
    ConsultationResponse.create!(user: user, consultation: consultation,
                                 response_round: ResponseRound.create!(consultation: consultation),
                                 visibility: :shared, response_status: :acceptable,
                                 response_text: 'citizen answer')
  end

  let(:prompts) { [] }

  before do
    allow_any_instance_of(described_class).to receive(:generate_summary) do |_svc, prompt|
      prompts << prompt
      'AI summary text'
    end
  end

  describe '#call' do
    it 'generates a summary for each of the five languages' do
      result = described_class.new(consultation).call

      expect(result[:success]).to be(true)
      expect(prompts.size).to eq(5)
      %w[English Hindi Marathi Odia Kannada].each do |language|
        expect(prompts.join).to include("OUTPUT LANGUAGE: #{language}")
      end
    end

    it 'stores the generated summaries on the consultation' do
      described_class.new(consultation).call

      %i[english hindi marathi odia kannada].each do |lang|
        expect(consultation.reload.public_send("#{lang}_response_summary").to_plain_text).to include('AI summary text')
      end
    end

    it 'includes the response text in the prompt' do
      described_class.new(consultation).call

      expect(prompts.first).to include('citizen answer')
      expect(prompts.first).to include(consultation.title)
    end

    it 'includes voice transcriptions in the prompt' do
      response.update_columns(voice_responses: [{ 'attachment_id' => 1, 'question_id' => 1, 'transcription' => 'spoken feedback' }])

      described_class.new(consultation).call

      expect(prompts.first).to include('Voice message transcription: spoken feedback')
    end

    it 'skips languages that already have a summary' do
      consultation.update!(english_response_summary: '<p>existing</p>')

      described_class.new(consultation).call

      expect(prompts.size).to eq(4)
      expect(prompts.join).not_to include('OUTPUT LANGUAGE: English')
      expect(consultation.reload.english_response_summary.to_plain_text).to include('existing')
    end

    it 'returns early without calling OpenAI when all summaries exist' do
      %i[english hindi marathi odia kannada].each do |lang|
        consultation.update!("#{lang}_response_summary" => '<p>done</p>')
      end

      result = described_class.new(consultation).call

      expect(result[:success]).to be(true)
      expect(prompts).to be_empty
    end

    context 'without acceptable responses' do
      let!(:response) { nil }

      it 'fails' do
        result = described_class.new(consultation).call

        expect(result[:success]).to be(false)
        expect(result[:message]).to match(/no acceptable responses/i)
        expect(prompts).to be_empty
      end
    end

    context 'when generation returns nothing for every language' do
      before do
        allow_any_instance_of(described_class).to receive(:generate_summary).and_return(nil)
      end

      it 'fails' do
        result = described_class.new(consultation).call

        expect(result[:success]).to be(false)
        expect(result[:message]).to match(/empty content for all languages/i)
      end
    end
  end

  describe 'Consultation#expire trigger' do
    it 'enqueues ConsultationSummaryJob when the english summary is missing' do
      expect { consultation.expire }.to have_enqueued_job(ConsultationSummaryJob)
    end

    it 'does not enqueue when the english summary already exists' do
      consultation.update!(english_response_summary: '<p>done</p>')

      expect { consultation.expire }.not_to have_enqueued_job(ConsultationSummaryJob)
    end

    context 'without acceptable responses' do
      let!(:response) { nil }

      it 'does not enqueue the job' do
        expect { consultation.expire }.not_to have_enqueued_job(ConsultationSummaryJob)
      end
    end
  end
end
