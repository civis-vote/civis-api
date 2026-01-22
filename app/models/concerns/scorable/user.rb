module Scorable
  module User
    extend ActiveSupport::Concern

    included do
      after_commit :add_user_created_points, on: :create if respond_to? :after_commit
      after_commit :add_user_created_points, if: :saved_change_to_city_id?
      def add_user_created_points
        add_points(:user_created)
        point_events = self.point_events.joins(:point_scale).where(point_scales: { action: "response_submitted" })
        consultation_responses = responses
        return unless !point_events.present? && consultation_responses.present?

        consultation_responses.each do |consultation_response|
          consultation_response.add_response_created_points
        end
      end
    end

    class << self
      def update_national_rank
        distinct_points = ::User.citizen.where.not(city_id: nil).distinct(:points).pluck(:points).sort.reverse
        distinct_points.each_with_index do |point_value, index|
          ::User.where(points: point_value).update_all(rank: index + 1)
        end
      end

      def update_state_rank(state)
        return false unless state.present?

        state_users = ::User.citizen.where(city_id: state.child_ids)
        distinct_points = state_users.distinct(:points).pluck(:points).sort.reverse
        distinct_points.each_with_index do |point_value, index|
          state_users.where(points: point_value).update_all(state_rank: index + 1)
        end
      end

      def update_city_rank(city)
        city_users = ::User.citizen.where(city_id: city.id)
        distinct_points = city_users.distinct(:points).pluck(:points).sort.reverse
        distinct_points.each_with_index do |point_value, index|
          city_users.where(points: point_value).update_all(city_rank: index + 1)
        end
      end
    end

    def add_points(action)
      point_scale = calculate_point_scale(action)
      point_event = point_events.create(point_scale: point_scale, points: point_scale.points)
      if !role?('admin') && city.present?
        User.update_national_rank
        User.update_state_rank(city.parent)
        User.update_city_rank(city)
        check_for_new_best_rank
      end
      point_event
    end

    def calculate_point_scale(action)
      current_points = points.to_i
      PointScale.where("upper_limit > ?", current_points).where(action: action).order(upper_limit: :asc).first
    end

    def check_for_new_best_rank
      update(best_rank: city_rank, best_rank_type: :city) unless best_rank.present?
      update(best_rank: city_rank, best_rank_type: :city) if city_rank.present? && best_rank > city_rank
      update(best_rank: state_rank, best_rank_type: :state) if state_rank.present? && best_rank > state_rank
      update(best_rank: rank, best_rank_type: :national) if rank.present? && best_rank > rank
    end
  end
end
