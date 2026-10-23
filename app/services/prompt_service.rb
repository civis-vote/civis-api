module PromptService
  PROMPTS_DIR = Rails.root.join('config/prompts').freeze

  class << self
    # Fetch a prompt template from CmPlatformSetting by slug.
    # Optionally interpolate variables passed as a hash.
    #
    # Example:
    #   PromptService.get('agent-clause-table-prompt')
    #   PromptService.get('agent-draft-summariser-prompt', title: consultation.title)
    def get(slug, variables = {})
      template = CmPlatformSetting.find_by(slug: slug)&.value
      return nil unless template

      interpolate(template, variables)
    end

    # Fetch a prompt template from a file in config/prompts/.
    # Optionally interpolate variables passed as a hash.
    def from_file(filename, variables = {})
      path = PROMPTS_DIR.join(filename)
      return nil unless File.exist?(path)

      template = File.read(path).strip
      interpolate(template, variables)
    end

    def clause_extraction
      get('agent-clause-table-prompt')
    end

    def draft_summarisation
      get('agent-draft-summariser-prompt')
    end

    def voice_transcription(context = {})
      context[:supported_languages] = ConsultationResponse::SUPPORTED_LANGUAGES.join(', ')
      from_file('voice_message_transcription.prompt', context)
    end

    private

    def interpolate(template, variables)
      return template if variables.blank?

      variables.reduce(template) do |result, (key, value)|
        placeholder = key.to_s.upcase
        result.gsub("{{#{placeholder}}}", value.to_s)
      end
    end
  end
end
