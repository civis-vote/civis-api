class VoiceMessageTranscriptionProcessor
  attr_reader :errors

  def initialize(consultation_response_id, attachment_id)
    @consultation_response_id = consultation_response_id
    @attachment_id = attachment_id
    @errors = []
  end

  def call
    return failure('ConsultationResponse not found') unless consultation_response
    return failure('Voice message attachment not found') unless attachment

    context = build_context
    result = VoiceMessageTranscriptionService.new(attachment, context).call

    if result[:success]
      update_voice_response_transcription(result)
    else
      mark_transcription_failed(result[:errors])
    end

    result
  end

  private

  def consultation_response
    @consultation_response ||= ConsultationResponse.find_by(id: @consultation_response_id)
  end

  def attachment
    return nil unless consultation_response

    @attachment ||= consultation_response.voice_messages.attachments.find_by(id: @attachment_id)
  end

  def build_context
    voice_entry = consultation_response.voice_responses.find do |entry|
      entry['attachment_id'] == @attachment_id || entry[:attachment_id] == @attachment_id
    end

    question_text = ''
    if voice_entry
      question_id = voice_entry['question_id'] || voice_entry[:question_id]
      question = Question.find_by(id: question_id) if question_id.present?
      question_text = question&.question_text.to_s
    end

    {
      consultation_topic: consultation_response.consultation&.title.to_s,
      response_language: consultation_response.response_language.to_s,
      question_text: question_text
    }
  end

  def update_voice_response_transcription(result)
    consultation_response.with_lock do
      voice_responses = consultation_response.voice_responses
      return if voice_responses.blank?

      voice_entry = voice_responses.find do |entry|
        entry['attachment_id'] == @attachment_id || entry[:attachment_id] == @attachment_id
      end
      return unless voice_entry

      updated = voice_responses.map do |entry|
        next entry unless entry['attachment_id'] == @attachment_id || entry[:attachment_id] == @attachment_id

        entry.merge(
          'transcription' => result[:transcription],
          'detected_language' => result[:detected_language],
          'confidence' => result[:confidence]
        )
      end

      question_id = voice_entry['question_id'] || voice_entry[:question_id]
      merged_answers = merge_transcription_into_answers(consultation_response.answers, question_id, result[:transcription])

      consultation_response.update!(
        voice_responses: updated,
        answers: merged_answers,
        transcription_status: :completed,
        transcription_errors: []
      )
    end
  end

  def merge_transcription_into_answers(answers, question_id, transcription)
    new_entry = { 'question_id' => question_id.to_s, 'answer' => transcription }
    return [new_entry] if answers.blank?

    found = false
    updated = answers.map do |ans|
      if ans['question_id'].to_s == question_id.to_s
        found = true
        ans.merge('answer' => transcription)
      else
        ans
      end
    end
    found ? updated : updated + [new_entry]
  end

  def mark_transcription_failed(errors)
    consultation_response.with_lock do
      consultation_response.update!(transcription_status: :failed, transcription_errors: errors)
    end
  end

  def failure(message)
    @errors << message
    { success: false, transcription: nil, detected_language: nil, confidence: nil, errors: @errors }
  end
end
