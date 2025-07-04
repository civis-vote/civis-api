module Scorable
  module Consultation
    extend ActiveSupport::Concern
    include Scorable

    included do
      before_save :add_consultation_created_points, if: :status_changed? if respond_to? :before_save

      def add_consultation_created_points
        if status_changed?(from: "submitted", to: "published") && public_consultation? &&
           !created_by.role?('admin') && created_by.city.present?
          created_by.add_points(:consultation_created)
        end
      end
    end
  end
end
