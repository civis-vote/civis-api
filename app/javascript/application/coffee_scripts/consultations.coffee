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
	$(document).on 'click', '#export-consultation-in-excel', () ->
		filter_params = undefined
		query_string = undefined
		sort_column = undefined
		sort_direction = undefined
		sort_column = $('[data-behaviour="current-page"]').data('sort-column'); 
		sort_direction = $('[data-behaviour="current-page"]').data('sort-direction');
		filter_params = {}
		$('[data-behaviour="filter"]').each (index) ->
		  filter_params[$(this).data('scope')] = $(this).val()
		  return
		query_string =
		  filters: filter_params
		  sort:
		    sort_column: sort_column
		    sort_direction: sort_direction
		current_request = $.ajax '/admin/consultations/export_as_excel',
			type: 'GET',
			data: query_string,
			beforeSend: ->
			  if current_request != null
			    current_request.abort()
			  return
			success:(data) -> 
				location.reload()