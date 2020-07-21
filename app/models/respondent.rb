class Respondent < ApplicationRecord
	include SpotlightSearch
	include Paginator

	belongs_to :user
	belongs_to :response_round
	belongs_to :organisation
	has_many :consultation_response

	scope :search_user_query, lambda { |query|
		return nil if query.blank?
		terms = query.downcase.split(/\s+/)
		terms = terms.map { |e|
			(e.gsub("*", "%").prepend("%") + "%").gsub(/%+/, "%")
		}
		num_or_conds = 3
		includes(:user).references(:user).
		where(
			terms.map { |term|
				"(LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ? OR LOWER(users.email) LIKE ? )"
			}.join(" AND "),
			*terms.map { |e| [e] * num_or_conds }.flatten,
		)
	}

	class << self
		def invite_respondent(consultation, organisation, respondent_ids, emails)
			if respondent_ids.present?
				consultation_response_rounds = Consultation.includes(:response_rounds)
				respondent_ids.each do |id, value|
					respondent = Respondent.find(id.to_i)
					response_round_ids = Respondent.where(user_id: respondent.user_id).map{|r| r.response_round_id }
	      	consultation_ids = consultation_response_rounds.where(response_rounds: { id: response_round_ids } ).map(&:id)
					unless consultation_ids.include? consultation.id
						Respondent.create(user_id: respondent.user_id, organisation_id: organisation.id, response_round_id: consultation.response_rounds.last.id)
						url = respondent_invite_url(consultation, respondent.user)
						InviteRespondentJob.perform_later(consultation, respondent.user, url) if consultation.published?
					end
				end
			end
			
	    emails.each do |email|
	    	user_record = create_respondent(email, organisation, consultation)
	      url = respondent_invite_url(consultation, user_record)
	      user_record.update(callback_url: "https://www.civis.vote/auth-private?email=")
	      InviteRespondentJob.perform_later(consultation, user_record, url) if consultation.published?
	    end
		end

		def create_respondent(email, organisation, consultation)
			user_record = User.find_by(email: email.strip)
	    if user_record
	    	respondent_record = Respondent.where(user_id: user_record.id, organisation_id: organisation.id, response_round_id: consultation.response_rounds.last.id)
	      Respondent.create(user_id: user_record.id, organisation_id: organisation.id, response_round_id: consultation.response_rounds.last.id) unless respondent_record.present?
	    else
	    	user_record = User.new(email: email.strip, confirmed_at: DateTime.now)
	    	user_record.save(validate: false)
	    	user_record = User.find_by(email: email.strip)
	    	Respondent.create(user_id: user_record.id, organisation_id: organisation.id, response_round_id: consultation.response_rounds.last.id)
	    end
	    return user_record
		end

		def respondent_invite_url(consultation, user_record)
			if Rails.env.development?
	      callback_url = URI::HTTP.build(Rails.application.config.host_url.merge!({path: "/consultations/#{consultation.id}/read"})).to_s
	      url = URI::HTTP.build(Rails.application.config.host_url.merge!({path: "/auth-private", query: "email=#{user_record.email}&first_name=#{user_record.first_name}&last_name=#{user_record.last_name}"})).to_s
	    else
	      callback_url = URI::HTTPS.build(Rails.application.config.host_url.merge!({path: "/consultations/#{consultation.id}/read"})).to_s
	      url = URI::HTTPS.build(Rails.application.config.host_url.merge!({path: "/auth-private", query: "email=#{user_record.email}&first_name=#{user_record.first_name}&last_name=#{user_record.last_name}"})).to_s
	    end
		end
	end
end