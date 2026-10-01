module StructuredOutputService
  class << self
    def clause_extraction
      clause_types = Constant.where(constant_type: :clause_type).pluck(:name)

      {
        type: 'json_schema',
        name: 'clause_extraction',
        strict: true,
        schema: {
          type: 'object',
          properties: {
            clauses: {
              type: 'array',
              description: 'Complete list of clauses extracted from the document',
              items: {
                type: 'object',
                properties: {
                  clause_id: { type: 'string', description: 'Hierarchical numbering (e.g., 1, 1.1, 2)' },
                  clause_title: { type: 'string', description: 'Max 8-10 words, plain English' },
                  what_is_proposed: { type: 'string', description: '1-3 lines, simple explanation of the change or rule' },
                  clause_type: {
                    type: 'string',
                    enum: clause_types,
                    description: 'The category of the clause'
                  },
                  stakeholder_impact: {
                    type: %w[string null],
                    description: 'Who is affected, kept brief, neutral, and factual'
                  },
                  keywords: {
                    type: 'array',
                    items: { type: 'string' },
                    description: '3-5 keyword strings for mapping'
                  }
                },
                required: %w[clause_id clause_title what_is_proposed clause_type stakeholder_impact keywords],
                additionalProperties: false
              }
            }
          },
          required: ['clauses'],
          additionalProperties: false
        }
      }
    end
  end
end
