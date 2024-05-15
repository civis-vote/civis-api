(function() {
  var current_request;

  current_request = null;

  $(document).on('turbo:load', function() {
    $(document).on('click', '#export-users-in-excel', function() {
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
      return current_request = $.ajax('/admin/users/export_as_excel', {
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
    return $(document).on('keyup', '#respondent_user_search', function() {
      var consultation_id, route, search_term, url;
      search_term = $('#respondent_user_search').val();
      consultation_id = $(this).data('consultation-id');
      route = $(this).data('route');
      if (route === "admin") {
        url = '/admin/consultations/' + consultation_id;
      } else {
        url = '/organisation/consultations/' + consultation_id;
      }
      return $.ajax(url, {
        type: 'GET',
        data: {
          search: search_term
        },
        success: function(data, jqxhr, textStatus) {
          return $('#invited-respondents-table').html(data);
        }
      });
    });
  });

}).call(this);
