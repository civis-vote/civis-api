(function() {
  var current_request;

  current_request = null;

  $(document).on('turbo:load', function() {
    var status_filter, url;
    if (window.location.href.indexOf('&filters%5Bstatus_filter%5D=published') > -1) {
      $('#published-consultations-link').addClass("active");
      $('#submitted-consultations-link').removeClass("active");
      $('#all-consultations-link').removeClass("active");
    } else if (window.location.href.indexOf('&filters%5Bstatus_filter%5D=submitted') > -1) {
      $('#submitted-consultations-link').addClass("active");
      $('#published-consultations-link').removeClass("active");
      $('#all-consultations-link').removeClass("active");
    } else {
      $('#all-consultations-link').addClass("active");
    }
    $(document).on('change', '#consultation_ministry_id', function() {
      var id, ministry_id;
      ministry_id = $(this).val();
      id = $(this).data('id');
      return current_request = $.ajax('/admin/consultations/' + id + '/check_active_ministry', {
        type: 'GET',
        data: {
          ministry_id: ministry_id
        },
        beforeSend: function() {
          if (current_request !== null) {
            current_request.abort();
          }
        },
        success: function(data) {
          return $('#consultation-ministry').html(data);
        }
      });
    });
    $(document).on('click', '#export-consultation-in-excel', function() {
      var filter_params, query_string, sort_column, sort_direction;
      filter_params = void 0;
      query_string = void 0;
      sort_column = void 0;
      sort_direction = void 0;
      sort_column = $('[data-behaviour="current-page"]').data('sort-column');
      sort_direction = $('[data-behaviour="current-page"]').data('sort-direction');
      filter_params = {};
      $('[data-behaviour="filter"]').each(function(index) {
        filter_params[$(this).data('scope')] = $(this).val();
      });
      query_string = {
        filters: filter_params,
        sort: {
          sort_column: sort_column,
          sort_direction: sort_direction
        }
      };
      return current_request = $.ajax('/admin/consultations/export_as_excel', {
        type: 'GET',
        data: query_string,
        beforeSend: function() {
          if (current_request !== null) {
            current_request.abort();
          }
        },
        success: function(data) {
          return location.reload();
        }
      });
    });
    url = window.location.href;
    status_filter = $('.nav-item .active').data('status-filter');
    if (url.indexOf("visibility_filter%5D=1") !== -1) {
      $('#status').parent().parent().addClass("d-none");
      $('.consultation-status-filter').removeClass('active');
      $('.private-consultation-block .consultation-status-filter').addClass("active");
    } else if (status_filter) {
      $('#status').parent().parent().addClass("d-none");
    }
    $(document).on('click', '.consultation-status-filter', function() {
      status_filter = $(this).data('status-filter');
      if (status_filter === 'private') {
        $('#status').parent().parent().addClass("d-none");
        $('#status option[value=\'published\']').remove();
        $('#status option[value=\'submitted\']').remove();
        $('#status').val("");
        return $('#private_consultation').val(1).trigger('change');
      } else if (status_filter) {
        $('#status').parent().parent().addClass("d-none");
        $('#status').append('<option value=' + status_filter + '>' + status_filter + '</option>');
        $('#private_consultation').val("");
        $('#status').val(status_filter).trigger('change');
      } else {
        $('#status option[value=\'published\']').remove();
        $('#status option[value=\'submitted\']').remove();
        $('#status').parent().parent().removeClass("d-none");
        $('#private_consultation').val("");
        $('#status').val(status_filter).trigger('change');
      }
    });
    $(document).on('click', '#options-fields-area #option-cross', function() {
      var row = $(this).closest('.checkbox-option-row');
      if (row.siblings('.checkbox-option-row').length > 0) {
        row.remove();
      }
    });
    
    $(document).on('click', '#options-fields-area-edit #option-cross', function() {
      var parent = $(this).closest('.checkbox-option-row');
      var id = parent.next().val();
      if (id=== undefined) {
        parent.remove();
      } else {
      parent.children().find('.sub_question_question_text').val("");
      parent.children().find('.sub_question_question_text_hindi').val("");
      parent.children().find('.sub_question_question_text_odia').val("");
      parent.hide();
      parent.find('.sub_question_destroy').val(id);
      }
    });

    
    $(document).on('click', '#add-option-btn', function() {
      var child, id, name, hindi_name, odia_name;
      
      child = $('#options-fields-area').children(':not(:hidden)').last().clone();
      
      child.find("input").val("");
      
      id = child.data('id');
      id = parseInt(id) + 1;
      child.attr('data-id', id);
      
      name = "question[sub_questions_attributes][" + id + "][question_text]";
      hindi_name = "question[sub_questions_attributes][" + id + "][question_text_hindi]";
      odia_name = "question[sub_questions_attributes][" + id + "][question_text_odia]";
      
      child.find(".input-box .form-group.string.optional.question_sub_questions_question_text input")
        .attr('name', name);
      child.find(".input-box .form-group.string.optional.question_sub_questions_question_text_hindi input")
        .attr('name', hindi_name);
      child.find(".input-box .form-group.string.optional.question_sub_questions_question_text_odia input")
        .attr('name', odia_name);
      
      child.find('.sub_question_destroy').val("").removeClass('hidden');
      
      $('#options-fields-area').append(child);
    });

    $(document).on('click', '.edit-add-option', function() {
      var child, id, name, hindi_name, odia_name;
      var parent = $(this).parent();
      var optionType = parent.find('select').val();
    
      if (optionType === "checkbox") {
        parent.find('.checkbox-option').removeClass("d-none");
      } else if (optionType === "multiple_choice" || optionType === "dropdown") {
        parent.find('.radio-button-option').removeClass("d-none");
      } else {
        parent.find('.checkbox-option').addClass("d-none");
        parent.find('.radio-button-option').addClass("d-none");
        parent.find('.cross-btn').addClass("d-none");
      }
    
      child = parent.find('#options-fields-area-edit .checkbox-option-row:not(:hidden)').last().clone().removeClass("d-none");
      child.find(".question_sub_questions__destroy").remove();
    
      child.find(".input-box input").val("");
    
      var existingRowsCount = parent.find('#options-fields-area-edit .checkbox-option-row').length;
      id = existingRowsCount;
      name = "question[sub_questions_attributes][" + id + "][question_text]";
      hindi_name = "question[sub_questions_attributes][" + id + "][question_text_hindi]";
      odia_name = "question[sub_questions_attributes][" + id + "][question_text_odia]";
    
      child.find(".input-box .form-group.string.optional.question_sub_questions_question_text input")
        .attr('name', name);
      child.find(".input-box .form-group.string.optional.question_sub_questions_question_text_hindi input")
        .attr('name', hindi_name);
      child.find(".input-box .form-group.string.optional.question_sub_questions_question_text_odia input")
        .attr('name', odia_name);
    
      parent.find('#options-fields-area-edit').append(child);
    });
    
    
    $('#new_question #options-fields-area .checkbox-option-row').addClass("d-none");
    $('.question_question_type select').each(function() {
      if ($(this).val() === "checkbox") {
        return $(this).parent().parent().children().find('.radio-button-option').addClass('d-none');
      } else if ($(this).val() === "multiple_choice" || $(this).val() === "dropdown") {
        return $(this).parent().parent().children().find('.checkbox-option').addClass('d-none');
      } else {
        $(this).parent().parent().children().find('.radio-button-option').addClass('d-none');
        $(this).parent().parent().children().find('.checkbox-option').addClass('d-none');
        return $(this).parent().parent().find('.edit-add-option').addClass('d-none');
      }
    });
    $(document).on('change', '#new_question #question_question_type', function() {
      if ($(this).val() === "checkbox") {
        $('#add-option-btn').removeClass("d-none");
        $('.supports-other-toggle').removeClass("d-none");
        $('.checkbox-option-row').removeClass("d-none");
        $('.checkbox-option').removeClass("d-none");
        return $('.radio-button-option').addClass("d-none");
      } else if ($(this).val() === "multiple_choice" || $(this).val() === "dropdown") {
        $('#add-option-btn').removeClass("d-none");
        $('.supports-other-toggle').removeClass("d-none");
        $('.checkbox-option-row').removeClass("d-none");
        $('.checkbox-option').addClass("d-none");
        return $('.radio-button-option').removeClass("d-none");
      } else {
        $('#add-option-btn').addClass("d-none");
        $('.supports-other-toggle').addClass("d-none");
        return $('.checkbox-option-row').addClass("d-none");
      }
    });
    $(document).on('change', '.edit_question .question_question_type select', function() {
      if ($(this).val() === "checkbox") {
        $(this).parent().parent().find('.edit-add-option').removeClass('d-none');
        $(this).parent().parent().find('.supports-other-toggle').removeClass('d-none');
        $(this).parent().parent().find('.checkbox-option-row').removeClass("d-none");
        $(this).parent().parent().find('.checkbox-option').removeClass("d-none");
        return $(this).parent().parent().find('.radio-button-option').addClass("d-none");
      } else if ($(this).val() === "multiple_choice" || $(this).val() === "dropdown") {
        $(this).parent().parent().find('.edit-add-option').removeClass("d-none");
        $(this).parent().parent().find('.supports-other-toggle').removeClass("d-none");
        $(this).parent().parent().find('.checkbox-option-row').removeClass("d-none");
        $(this).parent().parent().find('.checkbox-option').addClass("d-none");
        return $(this).parent().parent().find('.radio-button-option').removeClass("d-none");
      } else {
        $(this).parent().parent().find('.edit-add-option').addClass("d-none");
        $(this).parent().parent().find('.supports-other-toggle').addClass("d-none");
        $(this).parent().parent().find('.checkbox-option-row').addClass("d-none");
        return $(this).parent().parent().find('.edit-options-fields .checkbox-option-row').each(function() {
          var id, parent;
          parent = $(this);
          id = parent.next().val();
          parent.find('.sub_question_destroy').val(id);
          return parent.addClass('d-none');
        });
      }
    });
    $(document).on('click', '#private_response_toggle', function() {
      if ($(this).prop('checked')) {
        return $(this).val("1");
      } else {
        return $(this).val("0");
      }
    });
    $(document).on('click', '.optional_toggle', function() {
      if ($(this).prop('checked')) {
        return $(this).val("1");
      } else {
        return $(this).val("0");
      }
    });
    $(document).on('click', '.validate-question-option', function(e) {
      var form, option_empty, question_text, question_type;
      e.preventDefault();
      form = $(this).parents('form');
      form.find('.validation-error').addClass("d-none");
      question_text = form.children('.question_question_text').children('input').val();
      question_type = form.children('.question_question_type').children('select').val();
      if (question_text === "") {
        return form.find('.validation-question-text').removeClass("d-none");
      } else if (question_type === "") {
        return form.find('.validation-question-type').removeClass("d-none");
      } else if (question_type !== "long_text") {
        option_empty = false;
        form.find('.checkbox-option-row').each(function() {
          if ($(this).find('input').val() === "") {
            return option_empty = true;
          }
        });
        if (option_empty === true) {
          return form.find('.validation-question-option').removeClass("d-none");
        } else {
          return form.submit();
        }
      } else {
        return form.submit();
      }
    });
    $(document).on('keypress', '.sub_question_text', function(e) {
      var edit_option_fields, element, key;
      key = e.which;
      element = $(this);
      edit_option_fields = element.parent().parent().parent().parent().hasClass("edit-options-fields");
      if (key === 13) {
        if (edit_option_fields === true) {
          $('.edit-add-option').click();
          return false;
        } else {
          $('#add-option-btn').click();
          return false;
        }
      }
    });
    return $(document).on('click', '#file-upload-btn', function(e) {
      return $('#loader-for-file-upload').removeClass("hidden");
    });
  });

}).call(this);
