$(document).on 'click', '.submit-ministry', (e)->
  if $('#ministry_poc_email_primary').val() == ""
    $('#validation_primary_email').removeClass 'hidden'
    e.preventDefault()
  else
    $(this).submit()

$(document).on 'keyup', '#ministry_poc_email_primary', () ->
  if $('#ministry_poc_email_primary').val() == ""
    $('#validation_primary_email').removeClass 'hidden'
  else
    $('#validation_primary_email').addClass 'hidden'
