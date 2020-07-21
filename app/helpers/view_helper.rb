module ViewHelper

	def display_details(parent, label_class, label_value, input_class, input_value)
		"<div class=#{parent}>
		<div class=#{label_class}>#{label_value}</div>
		<div class=#{input_class}>#{input_value}</div>
		</div>".html_safe
	end

	def consultation_status_text(consultation)
		case consultation.status
		when "submitted"
    	return "DRAFT"
    when "published"
    	return "ACTIVE"
    else
    	return "CLOSED"
  	end
	end

	def respondent_name_and_email(user)
		if user.first_name?
			"<div class='employee-name'>
				#{user.full_name}
			</div>
			<span class='child-invite-span'>
				#{user.email}
			</span>".html_safe
	  else
	  	"<div class='employee-name'>
	      #{user.email}
	    </div>
    	<span class='child-invite-span'>
    		Invited
    	</span>".html_safe
	  end
	end

	def check_respondent_present_in_other_consultation(user_id, consultation_response_rounds, consultation, respondent)
		response_round_ids = Respondent.where(user_id: user_id).map{|r| r.response_round_id }
  	consultation_ids = consultation_response_rounds.where(response_rounds: { id: response_round_ids } ).map(&:id)
  	if consultation_ids.include? consultation.id
			"<input id=invite-respondent-#{respondent.id} class='pull-right invite-respondent-checkbox' type=checkbox name=respondent[ids][#{respondent.id}] checked=checked>
			<label for=invite-respondent-#{respondent.id}></label>".html_safe
  	else
  		"<input id=invite-respondent-#{respondent.id} class='pull-right invite-respondent-checkbox' type=checkbox name=respondent[ids][#{respondent.id}]>
			<label for=invite-respondent-#{respondent.id}></label>".html_safe
		end
	end
end