module Types
  module Inputs
    module Ministry
      class Create < Types::BaseInputObject
        argument :category_id, Int, nil, required: true
        argument :level, Types::Enums::MinistryLevels, nil, required: true
        argument :logo_file, Types::Inputs::Attachment, nil, required: true
        argument :name, String, nil, required: true
        argument :department_contacts_attributes, [Types::Inputs::Ministry::DepartmentContact], nil, required: true
      end
    end
  end
end
