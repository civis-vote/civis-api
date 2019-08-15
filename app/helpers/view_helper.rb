module ViewHelper

	def display_details(parent, label_class, label_value, input_class, input_value)
		"<div class=#{parent}>
		<div class=#{label_class}>#{label_value}</div>
		<div class=#{input_class}>#{input_value}</div>
		</div>".html_safe
	end

end