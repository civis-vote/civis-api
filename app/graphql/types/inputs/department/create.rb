module Types
  module Inputs
    module Department
      class Create < Types::BaseInputObject
        argument :theme_id, Int, nil, required: true
        argument :level, Types::Enums::DepartmentLevels, nil, required: true
        argument :logo_file, Types::Inputs::Attachment, nil, required: true
        argument :name, String, nil, required: true
        argument :department_contacts_attributes, [Types::Inputs::Department::DepartmentContact], nil, required: true
      end
    end
  end
end
