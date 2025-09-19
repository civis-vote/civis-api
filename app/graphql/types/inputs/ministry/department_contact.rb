module Types
  module Inputs
    module Ministry
      class DepartmentContact < Types::BaseInputObject
        argument :email, String, nil, required: true
        argument :name, String, nil, required: true
        argument :designation, String, nil, required: true
      end
    end
  end
end
