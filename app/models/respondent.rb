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

	private

	class << self
		def invite_respondent(consultation, organisation, respondent_ids, emails)
			if respondent_ids.present?
				consultation_response_rounds = Consultation.includes(:response_rounds)
				invite_other_consultation_respondents(respondent_ids, consultation_response_rounds, consultation, organisation)
			end
			invite_new_respondent_via_email(emails, organisation, consultation) if emails.present?
		end

		def invite_new_respondent_via_email(emails, organisation, consultation)
			emails.each do |email|
	    	user_record = create_respondent(email, organisation, consultation)
	      user_record.update(callback_url: "https://www.civis.vote/auth-private?email=")
	      invite_respondent_email_job(consultation, user_record)
	    end
		end

		def invite_other_consultation_respondents(respondent_ids, consultation_response_rounds, consultation, organisation)
			respondent_ids.each do |id, value|
				respondent = Respondent.find(id.to_i)
				response_round_ids = Respondent.where(user_id: respondent.user_id).map{|r| r.response_round_id }
      	consultation_ids = consultation_response_rounds.where(response_rounds: { id: response_round_ids } ).map(&:id)
				unless consultation_ids.include? consultation.id
					respondent = create_respondent_record(respondent.user_id, organisation.id, consultation.response_rounds.last.id)
					invite_respondent_email_job(consultation, respondent.user)
				end
			end
		end

		def create_respondent(email, organisation, consultation)
			user_record = User.find_by(email: email.strip)
	    if user_record
	    	respondent_record = Respondent.where(user_id: user_record.id, organisation_id: organisation.id, response_round_id: consultation.response_rounds.last.id)
	    	create_respondent_record(user_record.id, organisation.id, consultation.response_rounds.last.id) unless respondent_record.present?
	    else
	    	user_record = create_user_record(email.strip, DateTime.now)
	    	create_respondent_record(user_record.id, organisation.id, consultation.response_rounds.last.id)
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

		def invite_respondent_email_job(consultation, user_record)
			url = respondent_invite_url(consultation, user_record)
			InviteRespondentJob.perform_later(consultation, user_record, url) if consultation.published?
		end

		def create_user_record(email, confirmed_at)
			user_record = User.new(email: email, confirmed_at: confirmed_at)
    	user_record.save(validate: false)
    	user_record = User.find_by(email: email.strip)
    	return user_record
		end

		def create_respondent_record(user_id, organisation_id, response_round_id)
			Respondent.create(user_id: user_id, organisation_id: organisation_id, response_round_id: response_round_id)
		end
	end
end