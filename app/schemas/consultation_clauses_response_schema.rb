class ConsultationClausesResponseSchema < RubyLLM::Schema
  array :clauses do
    object do
      string :clause_id, description: "Unique identifier for the clause"
      string :clause_title, description: "Title of the clause"
      string :what_is_proposed, description: "What is being proposed in this clause"
      string :clause_type, description: "Type of the clause (e.g., Policy, Regulation, Amendment)"
      string :stakeholder_impact, description: "Impact on stakeholders"
      array :keywords, of: :string, description: "Keywords associated with the clause"
    end
  end
end
