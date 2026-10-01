module PromptService
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

      return template if variables.blank?

      variables.reduce(template) do |result, (key, value)|
        result.gsub("{{#{key}}}", value.to_s)
      end
    end

    def clause_extraction
      get('agent-clause-table-prompt')
    end

    def draft_summarisation
      get('agent-draft-summariser-prompt')
    end
  end
end
