import 'jquery/dist/jquery.min';
import 'bootstrap/js/dist/alert'
import 'bootstrap/js/dist/button'
import 'bootstrap/js/dist/carousel'
import 'bootstrap/js/dist/collapse'
import 'bootstrap/js/dist/dropdown'
import 'bootstrap/js/dist/index'
import 'bootstrap/js/dist/modal'
import 'bootstrap/js/dist/popover'
import 'bootstrap/js/dist/scrollspy'
import 'bootstrap/js/dist/tab'
import 'bootstrap/js/dist/toast'
import 'bootstrap/js/dist/tooltip'
import 'bootstrap/js/dist/util'
import 'select2';
import 'pc-bootstrap4-datetimepicker';
import 'trix/dist/trix';
import 'cocoon-js';

current_request = null
select2_form_input_ui = ->
  $('.form-select-label-group select').each ->
    if $(this).val().length != 0
      $(this).parent().find('.select2-container--default').addClass('placeholder-padding')
      $(this).parent().find('label').removeClass('d-none')
    else
      $(this).parent().find('.select2-container--default').removeClass('placeholder-padding')
      $(this).parent().find('label').addClass('d-none')
    if $(this).data("id") && $(this).data("value")
      id = $(this).data("id")
      value = $(this).data("value")
      selectedOption = $('<option selected=\'selected\'></option>').val(id).text(value) 
      $(this).append(selectedOption).trigger 'change'

$(document).on 'turbolinks:load', ->
  $('.alert').delay(3000).slideUp 1000
  $('[data-toggle="tooltip"]').tooltip()
  return

$(document).on 'turbolinks:load', ->
  $ ->
    $('.datepicker').datetimepicker
      format: 'YYYY-MM-DD hh:mm A'
      icons: {
        time: "fa fa-clock",
        date: "fa fa-calendar",
        up: "fa fa-chevron-up",
        down: "fa fa-chevron-down"
      }
      minDate: new Date
    return
    $.each($(".datepicker"), () -> 
      $(this).val($(this).attr("data-value"))
    )
  fasterPreview = (uploader) ->
    if uploader.files and uploader.files[0]
      $('#profileImage').attr 'src', window.URL.createObjectURL(uploader.files[0])
    return

  $('#profileImage').click (e) ->
    $('#imageUpload').click()
    return

  $('#imageUpload').change ->
    fasterPreview this
    return

  $(window).on 'load', ->
    $ -> select2_form_input_ui()
  $('.select2').select2()
  $(document).on 'change', '.form-select-label-group select', () -> 
    if $(this).val().length != 0
      $(this).parent().find('.select2-container--default').addClass('placeholder-padding')
      $(this).parent().find('label').removeClass('d-none slidedown')
    else
      $(this).parent().find('.select2-container--default').removeClass('placeholder-padding')
      $(this).parent().find('label').addClass('d-none slideup')
  $('.questions-rounds-tab li').click (e) ->
    #get selected href
    href = $(this).find('a').attr('href')
    #set all nav tabs to inactive
    $('.questions-rounds-tab li').removeClass 'active'
    #get all nav tabs matching the href and set to active
    $('.questions-rounds-tab li a[href="' + href + '"]').closest('li').addClass 'active'
    #active tab
    $('.tab-pane').removeClass 'active'
    $('#' + href).addClass 'active'
    return
  copyToClipboard = (text, el) ->
    copyTest = document.queryCommandSupported('copy')
    elOriginalText = el.attr('data-original-title')
    if copyTest == true
      copyTextArea = document.createElement('textarea')
      copyTextArea.value = text
      document.body.appendChild copyTextArea
      copyTextArea.select()
      try
        successful = document.execCommand('copy')
        msg = if successful then 'Copied!' else 'Whoops, not copied!'
        el.attr('data-original-title', msg).tooltip 'show'
      catch err
        console.log 'Oops, unable to copy'
      document.body.removeChild copyTextArea
      el.attr 'data-original-title', elOriginalText
    else
      # Fallback if browser doesn't support .execCommand('copy')
      window.prompt 'Copy to clipboard: Ctrl+C or Command+C, Enter', text
    return

  $(document).ready ->
    # Initialize
    # ---------------------------------------------------------------------
    # Tooltips
    # Requires Bootstrap 3 for functionality
    $('.js-tooltip').tooltip()
    # Copy to clipboard
    # Grab any text in the attribute 'data-copy' and pass it to the 
    # copy function
    $('.js-copy').click ->
      text = $(this).attr('data-copy')
      el = $(this)
      copyToClipboard text, el
      return
    return