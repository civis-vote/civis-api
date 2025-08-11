module Scorable
  module ConsultationResponse
    extend ActiveSupport::Concern

    included do
      # after_commit :add_response_created_points, on: :create if respond_to? :after_commit
      def add_response_created_points
        return unless user.present? && !user.role?('admin') && user.city.present?

        points_to_add = 0.0
        point_event = user.add_points(:response_submitted)
        points_to_add += point_event.points
        if shared?
          point_event = user.add_points(:public_response_submitted)
          points_to_add += point_event.points
        end
        update(points: points_to_add)
        template.user.add_points(:response_used) if template.present?
      end
    end
  end
end
