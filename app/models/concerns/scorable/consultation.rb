module Scorable
  module Consultation
    extend ActiveSupport::Concern

    included do
      before_save :add_consultation_created_points, if: :status_changed? if respond_to? :before_save

      def add_consultation_created_points
        if status_changed?(from: "submitted", to: "published") && public_consultation? && created_by.city.present? &&
           %w[admin super_admin].exclude?(created_by.cm_role&.name&.parameterize&.underscore.to_s)
          created_by.add_points(:consultation_created)
        end
      end
    end
  end
end
