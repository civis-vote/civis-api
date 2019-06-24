Types::Objects::DateTimeType = GraphQL::ScalarType.define do 
  name "DateTime"

  coerce_input ->(value, _ctx) { Time.zone.parse(value) }
  coerce_result ->(value, _ctx) { value.to_datetime.utc.iso8601 }

end
