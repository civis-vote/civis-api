current_request = null

$(document).on 'turbolinks:load', ->
	$(document).on 'change', '#consultation_ministry_id', () ->
		ministry_id = $(this).val()
		id = $(this).data 'id'
		current_request = $.ajax '/admin/consultations/'+id+'/check_active_ministry',
			type: 'GET',
			data: { 
			  ministry_id : ministry_id 
			}
			beforeSend: ->
			  if current_request != null
			    current_request.abort()
			  return
			success:(data) -> 
				$('#consultation-ministry').html data