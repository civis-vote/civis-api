require 'ruby_llm/schema'

class VoiceMessageTranscriptionSchema < RubyLLM::Schema
  string :transcription, description: "The transcribed text of the voice message"
  string :detected_language, description: "The detected language of the speech (e.g. English, Hindi, Marathi, Odia)"
  number :confidence, description: "Confidence score of the transcription, between 0.0 and 1.0", minimum: 0, maximum: 1
end
