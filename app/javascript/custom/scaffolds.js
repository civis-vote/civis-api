var current_request, select2_form_input_ui;

current_request = null;

select2_form_input_ui = function() {
  return $('.form-select-label-group select').each(function() {
    var id, selectedOption, value;
    if ($(this).val().length !== 0) {
      $(this).parent().find('.select2-container--default').addClass('placeholder-padding');
      $(this).parent().find('label').removeClass('d-none');
    } else {
      $(this).parent().find('.select2-container--default').removeClass('placeholder-padding');
      $(this).parent().find('label').addClass('d-none');
    }
    if ($(this).data("id") && $(this).data("value")) {
      id = $(this).data("id");
      value = $(this).data("value");
      selectedOption = $('<option selected=\'selected\'></option>').val(id).text(value);
      return $(this).append(selectedOption).trigger('change');
    }
  });
};

$(document).on('turbo:load', function() {
  $('.alert').delay(3000).slideUp(1000);
  $('[data-toggle="tooltip"]').tooltip();
});

$(document).on('turbo:load', function() {
  var copyToClipboard, fasterPreview;
  $(function() {
    $('.datepicker').datetimepicker({
      format: 'YYYY-MM-DD hh:mm A',
      icons: {
        time: "fa fa-clock",
        date: "fa fa-calendar",
        up: "fa fa-chevron-up",
        down: "fa fa-chevron-down"
      },
      minDate: new Date
    });
    return $.each($(".datepicker"), function() {
      return $(this).val($(this).attr("data-value"));
    });
  });
  fasterPreview = function(uploader) {
    if (uploader.files && uploader.files[0]) {
      $('#profileImage').attr('src', window.URL.createObjectURL(uploader.files[0]));
    }
  };
  $('#profileImage').click(function(e) {
    $('#imageUpload').click();
  });
  $('#imageUpload').change(function() {
    fasterPreview(this);
  });
  $(window).on('load', function() {
    return $(function() {
      return select2_form_input_ui();
    });
  });
  $('.select2').select2();
  $(document).on('change', '.form-select-label-group select', function() {
    if ($(this).val().length !== 0) {
      $(this).parent().find('.select2-container--default').addClass('placeholder-padding');
      return $(this).parent().find('label').removeClass('d-none slidedown');
    } else {
      $(this).parent().find('.select2-container--default').removeClass('placeholder-padding');
      return $(this).parent().find('label').addClass('d-none slideup');
    }
  });
  $('.questions-rounds-tab li').click(function(e) {
    var href;
    href = $(this).find('a').attr('href');
    $('.questions-rounds-tab li').removeClass('active');
    $('.questions-rounds-tab li a[href="' + href + '"]').closest('li').addClass('active');
    $('.tab-pane').removeClass('active');
    $('#' + href).addClass('active');
  });
  copyToClipboard = function(text, el) {
    var copyTest, copyTextArea, elOriginalText, err, msg, successful;
    copyTest = document.queryCommandSupported('copy');
    elOriginalText = el.attr('data-original-title');
    if (copyTest === true) {
      copyTextArea = document.createElement('textarea');
      copyTextArea.value = text;
      document.body.appendChild(copyTextArea);
      copyTextArea.select();
      try {
        successful = document.execCommand('copy');
        msg = successful ? 'Copied!' : 'Whoops, not copied!';
        el.attr('data-original-title', msg).tooltip('show');
      } catch (error) {
        err = error;
        console.log('Oops, unable to copy');
      }
      document.body.removeChild(copyTextArea);
      el.attr('data-original-title', elOriginalText);
    } else {
      window.prompt('Copy to clipboard: Ctrl+C or Command+C, Enter', text);
    }
  };
  return $(document).ready(function() {
    $('.js-tooltip').tooltip();
    $('.js-copy').click(function() {
      var el, text;
      text = $(this).attr('data-copy');
      el = $(this);
      copyToClipboard(text, el);
    });
  });
});
