module Types
  module Objects
    class Clause < BaseObject
      graphql_name "BaseClauseType"
      field :id, Int, "ID of the clause", null: false
      field :clause_id, String, "Hierarchical numbering (e.g. 1, 1.1, 2)", null: false
      field :clause_title, String, nil, null: false
      field :what_is_being_proposed, String, nil, null: true
      field :clause_type, Types::Objects::Constant, nil, null: true
      field :stakeholder_impact, String, nil, null: true
      field :keywords, String, nil, null: true
    end
  end
end
