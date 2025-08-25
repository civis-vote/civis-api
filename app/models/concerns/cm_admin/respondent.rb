module CmAdmin
  module Respondent
    extend ActiveSupport::Concern

    included do
      cm_admin do
        actions only: %i[index destroy]
        set_icon 'far fa-newspaper'
        visible_on_sidebar false

        cm_index do
          page_title 'Respondents'

          filter %i[id user_id], :search, placeholder: 'Search'

          column :id
          column :email, field_type: :association, association_name: :user, association_type: 'belongs_to',
                         header: 'User'
          column :created_at, field_type: :date, format: '%d %b, %Y'
        end
      end
    end
  end
end
