current_request = null

$(document).on 'turbolinks:load', ->
	if window.location.href.indexOf('&filters%5Bstatus_filter%5D=published') > -1
		$('#published-consultations-link').addClass("active")
		$('#submitted-consultations-link').removeClass("active")
		$('#all-consultations-link').removeClass("active")
	else if window.location.href.indexOf('&filters%5Bstatus_filter%5D=submitted') > -1 
		$('#submitted-consultations-link').addClass("active")
		$('#published-consultations-link').removeClass("active")
		$('#all-consultations-link').removeClass("active")
	else
		$('#all-consultations-link').addClass("active")
	
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
	url = window.location.href
	status_filter = $('.nav-item .active').data 'status-filter'
	if url.indexOf("visibility_filter%5D=1") != -1
		$('#status').parent().parent().addClass("d-none")
		$('.consultation-status-filter').removeClass('active')
		$('.private-consultation-block .consultation-status-filter').addClass("active")
	else if status_filter
		$('#status').parent().parent().addClass("d-none")
	$(document).on 'click', '.consultation-status-filter', () ->
		status_filter = $(this).data 'status-filter'
		if status_filter == 'private'
			$('#status').parent().parent().addClass("d-none")
			$('#status option[value=\'published\']').remove()
			$('#status option[value=\'submitted\']').remove()
			$('#status').val("")
			$('#private_consultation').val(1).trigger 'change'
		else if status_filter
			$('#status').parent().parent().addClass("d-none")
			$('#status').append '<option value=' + status_filter + '>' + status_filter + '</option>'
			$('#private_consultation').val("")
			$('#status').val(status_filter).trigger 'change'
		else	
			$('#status option[value=\'published\']').remove()
			$('#status option[value=\'submitted\']').remove()
			$('#status').parent().parent().removeClass("d-none")
			$('#private_consultation').val("")
			$('#status').val(status_filter).trigger 'change'

	$(document).on 'click', '#option-cross', ()->
  		$(this).parent().parent().children().remove()

	$(document).on 'click', '#add-option-btn', ()->
		child = $('#options-fields-area').children(":nth-child(1)").clone()
		child.children().last().children(":nth-child(1)").removeClass('hidden')
		$('#options-fields-area').append(child)