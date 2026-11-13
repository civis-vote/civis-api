module Types
  module Objects
    class Theme < BaseObject
      field :id, Int, nil, null: false
      field :name, String, nil, null: false
      field :icon_name, String, nil, null: true
    end
  end
end
