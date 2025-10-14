module Types
  module Objects
    class DepartmentContact < BaseObject
      field :email, String, nil, null: false
      field :name, String, nil, null: true
      field :designation, String, nil, null: true
      field :contact_type, Types::Enums::DepartmentContactType, nil, null: true
    end
  end
end
