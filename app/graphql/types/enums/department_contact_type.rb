module Types
  module Enums
    class DepartmentContactType < Types::BaseEnum
      graphql_name 'DepartmentContactTypeEnum'

      ::DepartmentContact.contact_types.keys.each do |contact_type|
        send(:value, contact_type)
      end
    end
  end
end
