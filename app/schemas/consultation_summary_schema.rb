class ConsultationSummarySchema < RubyLLM::Schema
  string :summary, description: "Full markdown-formatted summary of the consultation document"
end
