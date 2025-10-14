module Types
  module Inputs
    module Department
      class DepartmentContact < Types::BaseInputObject
        graphql_name 'DepartmentContactInput'

        argument :email, String, nil, required: true
        argument :name, String, nil, required: false
        argument :designation, String, nil, required: false
        argument :contact_type, Types::Enums::DepartmentContactType, nil, required: true
      end
    end
  end
end
