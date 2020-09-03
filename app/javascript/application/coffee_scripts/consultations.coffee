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

	$(document).on 'click', '#options-fields-area #option-cross', ()->
  		$(this).parent().parent().remove() if $(this).parent().parent().parent().children().length > 1
	$(document).on 'click', '#options-fields-area-edit #option-cross', ()->
  	parent = $(this).parent().parent()
  	id = parent.next().val()
  	parent.find('.sub_question_destroy').val(id)
  	parent.remove()

	$(document).on 'click', '#add-option-btn', ()->
		child = $('#options-fields-area').children().last(":nth-child(1)").clone()
		child.find("input").val("")
		id = child.data 'id'
		id = parseInt(id) + 1
		child.attr("data-id",id)
		name = "question[sub_questions_attributes][" + id + "][question_text]"
		child.find("input").attr('name', name)
		child.children().last().children(":nth-child(1)").removeClass('hidden')
		$('#options-fields-area').append(child)
	$(document).on 'click', '.edit-add-option', ()->
		parent = $(this).parent()
		if parent.find('select').val() == "checkbox"
			parent.find('.checkbox-option').removeClass("d-none")
		else if ( parent.find('select').val() == "multiple_choice" || parent.find('select').val() == "dropdown" )
			parent.find('.radio-button-option').removeClass("d-none")
		else
			parent.find('.checkbox-option').addClass("d-none")
			parent.find('.radio-button-option').addClass("d-none")
			parent.find('.cross-btn').addClass("d-none")
		child = parent.find('#options-fields-area-edit .checkbox-option-row').last().clone()
		child = child.removeClass("d-none")
		child.find(".question_sub_questions__destroy").remove()
		child.find(".input-box input").val("")
		id = parent.find('#options-fields-area-edit .checkbox-option-row').length
		id = parseInt(id) + 1
		name = "question[sub_questions_attributes][" + id + "][question_text]"
		child.find(".input-box input").attr('name', name)
		parent.find('#options-fields-area-edit').append(child)
	$('#new_question #options-fields-area .checkbox-option-row').addClass("d-none")
	$('.question_question_type select').each () ->
		if $(this).val() == "checkbox"
			$(this).parent().parent().children().find('.radio-button-option').addClass('d-none')
		else if ( $(this).val() == "multiple_choice" || $(this).val() == "dropdown" )
			$(this).parent().parent().children().find('.checkbox-option').addClass('d-none')
		else
			$(this).parent().parent().children().find('.radio-button-option').addClass('d-none')
			$(this).parent().parent().children().find('.checkbox-option').addClass('d-none')
			$(this).parent().parent().find('.edit-add-option').addClass('d-none')
			
	$(document).on 'change', '#new_question #question_question_type', ()->
		if $(this).val() == "checkbox"
			$('#add-option-btn').removeClass("d-none")
			$('.supports-other-toggle').removeClass("d-none")
			$('.checkbox-option-row').removeClass("d-none")
			$('.checkbox-option').removeClass("d-none")
			$('.radio-button-option').addClass("d-none")
		else if ( $(this).val() == "multiple_choice" || $(this).val() == "dropdown" )
			$('#add-option-btn').removeClass("d-none")
			$('.supports-other-toggle').removeClass("d-none")
			$('.checkbox-option-row').removeClass("d-none")
			$('.checkbox-option').addClass("d-none")
			$('.radio-button-option').removeClass("d-none")
		else
			$('#add-option-btn').addClass("d-none")
			$('.supports-other-toggle').addClass("d-none")
			$('.checkbox-option-row').addClass("d-none")
	$(document).on 'change', '.edit_question .question_question_type select', ()->
		if $(this).val() == "checkbox"
			$(this).parent().parent().find('.edit-add-option').removeClass('d-none')
			$(this).parent().parent().find('.supports-other-toggle').removeClass('d-none')
			$(this).parent().parent().find('.checkbox-option-row').removeClass("d-none")
			$(this).parent().parent().find('.checkbox-option').removeClass("d-none")
			$(this).parent().parent().find('.radio-button-option').addClass("d-none")
		else if ( $(this).val() == "multiple_choice" || $(this).val() == "dropdown" )
			$(this).parent().parent().find('.edit-add-option').removeClass("d-none")
			$(this).parent().parent().find('.supports-other-toggle').removeClass("d-none")
			$(this).parent().parent().find('.checkbox-option-row').removeClass("d-none")
			$(this).parent().parent().find('.checkbox-option').addClass("d-none")
			$(this).parent().parent().find('.radio-button-option').removeClass("d-none")
		else
			$(this).parent().parent().find('.edit-add-option').addClass("d-none")
			$(this).parent().parent().find('.supports-other-toggle').addClass("d-none")
			$(this).parent().parent().find('.checkbox-option-row').addClass("d-none")
			$(this).parent().parent().find('.edit-options-fields .checkbox-option-row').each () ->
				parent = $(this)
				id = parent.next().val()
				parent.find('.sub_question_destroy').val(id)
				parent.addClass('d-none')
	$(document).on 'click', '#private_response_toggle', ()->
		if $(this).prop('checked')
			$(this).val("1")
		else
			$(this).val("0")
	$(document).on 'click', '.optional_toggle', ()->
		if $(this).prop('checked')
			$(this).val("1")
		else
			$(this).val("0")
	$(document).on 'click', '.validate-question-option', (e)->
		e.preventDefault()
		form = $(this).parents('form')
		form.find('.validation-error').addClass("d-none")
		question_text = form.children('.question_question_text').children('input').val()
		question_type = form.children('.question_question_type').children('select').val()
		if question_text == ""
			form.find('.validation-question-text').removeClass("d-none")
		else if question_type == ""
			form.find('.validation-question-type').removeClass("d-none")
		else if question_type != "long_text"
			option_empty = false
			form.find('.checkbox-option-row').each ->
				option_empty = true if $(this).find('input').val() == ""
			if option_empty == true
				form.find('.validation-question-option').removeClass("d-none")
			else
				form.submit()
		else
			form.submit()
	$(document).on 'keypress', '.sub_question_text', (e) ->
	  key = e.which
	  element = $(this)
	  edit_option_fields = element.parent().parent().parent().parent().hasClass("edit-options-fields")
	  if key == 13
	  	if edit_option_fields == true
		    $('.edit-add-option').click()
		    return false
		  else
		  	$('#add-option-btn').click()
		  	return false
	  return