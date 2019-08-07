module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

  	field :constant_for_type,			     resolver: Queries::Constant::ForType
  	field :consultation_list,			     resolver: Queries::Consultation::List
    field :consultation_response_list, resolver: Queries::ConsultationResponse::List
  	field :consultation_profile,		   resolver: Queries::Consultation::Profile
  	field :location_list, 				     resolver: Queries::Location::List
  	field :location_autocomplete,      resolver: Queries::Location::Autocomplete
  	field :ministry_autocomplete,      resolver: Queries::Ministry::Autocomplete
  	field :user_current,					     resolver: Queries::User::CurrentUser
  end
end