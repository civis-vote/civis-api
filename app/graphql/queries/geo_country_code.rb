module Queries
  class GeoCountryCode < Queries::BaseQuery
    description "Get a single country code"

    type String, null: true

    def resolve
      ::CmGeoIpNetwork.geo_country_iso_code(Current.ip_address)
    end
  end
end
