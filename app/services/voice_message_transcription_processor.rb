class VoiceMessageTranscriptionProcessor
  attr_reader :errors

  def initialize(consultation_response_id, attachment_id)
    @consultation_response_id = consultation_response_id
    @attachment_id = attachment_id
    @errors = []
  end

  def call
    return failure('ConsultationResponse not found') unless consultation_response

    unless attachment
      mark_transcription_failed(['Voice message attachment not found'])
      return failure('Voice message attachment not found')
    end

    result = VoiceMessageTranscriptionService.new(attachment, build_context).call

    if result[:success] && result[:is_proper_transcription]
      update_voice_response_transcription(result)
    elsif result[:success]
      mark_transcription_failed(['Transcription is not proper — audio may be inaudible or unintelligible'])
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
    @attachment ||= consultation_response&.voice_messages&.attachments&.find_by(id: @attachment_id)
  end

  def build_context
    {
      consultation_topic: consultation_response.consultation&.title.to_s,
      response_language: consultation_response.response_language.to_s,
      question_text: Question.find_by(id: entry_value(voice_entry, :question_id))&.question_text.to_s
    }
  end

  def voice_entry
    Array(consultation_response.voice_responses).find { |entry| attachment_entry?(entry) }
  end

  def attachment_entry?(entry)
    entry_value(entry, :attachment_id) == @attachment_id
  end

  def entry_value(entry, key)
    entry&.[](key.to_s) || entry&.[](key.to_sym)
  end

  def update_voice_response_transcription(result)
    consultation_response.with_lock do
      voice_responses = consultation_response.voice_responses
      entry = voice_entry
      return if voice_responses.blank? || entry.nil?

      updated = voice_responses.map do |e|
        next e unless attachment_entry?(e)

        e.merge(
          'transcription' => result[:transcription],
          'detected_language' => result[:detected_language]
        )
      end

      consultation_response.assign_attributes(
        voice_responses: updated,
        answers: merge_transcription_into_answers(consultation_response.answers, entry_value(entry, :question_id), result[:transcription]),
        transcription_status: (updated.all? { |e| e['transcription'].present? } ? :completed : :pending),
        transcription_errors: []
      )
      consultation_response.save(validate: false)
    end
  end

  def merge_transcription_into_answers(answers, question_id, transcription)
    new_entry = { 'question_id' => question_id.to_s, 'answer' => transcription }
    return [new_entry] if answers.blank?
    return answers + [new_entry] if answers.none? { |a| a['question_id'].to_s == question_id.to_s }

    answers.map do |ans|
      next ans unless ans['question_id'].to_s == question_id.to_s && ans['answer'].blank?

      ans.merge('answer' => transcription)
    end
  end

  def mark_transcription_failed(errors)
    consultation_response.with_lock do
      siblings_pending = Array(consultation_response.voice_responses).any? do |entry|
        !attachment_entry?(entry) && entry['transcription'].blank?
      end

      consultation_response.assign_attributes(
        transcription_status: (siblings_pending ? :pending : :failed),
        transcription_errors: errors
      )
      consultation_response.save(validate: false)
    end
  end

  def failure(message)
    @errors << message
    { success: false, transcription: nil, detected_language: nil,
      is_proper_transcription: false, errors: @errors }
  end
end
