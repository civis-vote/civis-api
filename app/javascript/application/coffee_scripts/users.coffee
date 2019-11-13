current_request = null

$(document).on 'turbolinks:load', ->
	$(document).on 'click', '#export-users-in-excel', () ->
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
		current_request = $.ajax '/admin/users/export_as_excel',
			type: 'GET',
			data: query_string,
			beforeSend: ->
			  if current_request != null
			    current_request.abort()
			  return
			success:(data) -> 
				location.reload()