module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :case_study_list,                    resolver: Queries::CaseStudy::List
    field :case_study_profile,                 resolver: Queries::CaseStudy::Profile
  	field :category_list,			                 resolver: Queries::Category::List
  	field :consultation_list,                  resolver: Queries::Consultation::List
    field :consultation_analysis,              resolver: Queries::Consultation::Analysis
    field :consultation_response_list,         resolver: Queries::ConsultationResponse::List
    field :consultation_response_profile,      resolver: Queries::ConsultationResponse::Profile
    field :consultation_response_venter_map,   resolver: Queries::ConsultationResponse::VenterMap
  	field :consultation_profile,		           resolver: Queries::Consultation::Profile
    field :impact_stats,                       resolver: Queries::Stats::Impact
  	field :location_list, 				             resolver: Queries::Location::List
  	field :location_autocomplete,              resolver: Queries::Location::Autocomplete
  	field :ministry_autocomplete,              resolver: Queries::Ministry::Autocomplete
  	field :user_current,					             resolver: Queries::User::CurrentUser
    field :user_list,                          resolver: Queries::User::List
    field :user_profile,                       resolver: Queries::User::Profile
    field :glossary_list,                      resolver: Queries::Glossary::List
    field :glossary_word,                      resolver: Queries::Glossary::Profile
    field :user_count_user,                    resolver: Queries::UserCount::User
  end
end