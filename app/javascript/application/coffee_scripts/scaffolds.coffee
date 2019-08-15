import 'bootstrap/js/dist/tooltip';

$(document).on 'turbolinks:load', ->
  $('.alert').delay(3000).slideUp 1000
  $('[data-toggle="tooltip"]').tooltip()
  return
