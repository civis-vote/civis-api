module Scorable
  module User
    extend ActiveSupport::Concern
    include Scorable

    included do 

	    after_commit :add_user_created_points, on: :create if respond_to? :after_commit
      after_commit :add_user_created_points, if: :saved_change_to_city_id?
	    def add_user_created_points
	    	self.add_points(:user_created)
        point_events = self.point_events.joins(:point_scale).where(point_scales: {action: "response_submitted"})
        consultation_responses = self.responses
        if !point_events.present? && consultation_responses.present?
          consultation_responses.each do | consultation_response|
            consultation_response.add_response_created_points
          end
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
    	point_event = self.point_events.create(point_scale: point_scale, points: point_scale.points)
      if !self.admin? && self.city.present?
        User.update_national_rank
        User.update_state_rank(self.city.parent)
        User.update_city_rank(city)
        self.check_for_new_best_rank
      end
      return point_event
    end

    def calculate_point_scale(action)
    	if PointScale.where("upper_limit > ?", self.points).where(action: action).order(upper_limit: :asc).present?
    		point_scale = PointScale.where("upper_limit > ?", self.points).where(action: action).order(upper_limit: :asc).first
    		return point_scale
    	else
    		puts "Could not find point scale!"
    	end
    end

    def check_for_new_best_rank
      self.update(best_rank: self.city_rank, best_rank_type: :city) unless self.best_rank.present?
      self.update(best_rank: self.city_rank, best_rank_type: :city) if self.city_rank.present? && self.best_rank > self.city_rank
      self.update(best_rank: self.state_rank, best_rank_type: :state) if self.state_rank.present? && self.best_rank > self.state_rank
      self.update(best_rank: self.rank, best_rank_type: :national) if self.rank.present? && self.best_rank > self.rank   
    end
  end
end