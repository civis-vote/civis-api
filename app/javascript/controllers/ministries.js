(function() {
  $(document).on('click', '.submit-ministry', function(e) {
    if ($('#ministry_poc_email_primary').val() === "") {
      $('#validation_primary_email').removeClass('hidden');
      return e.preventDefault();
    } else {
      return $(this).submit();
    }
  });

  $(document).on('keyup', '#ministry_poc_email_primary', function() {
    if ($('#ministry_poc_email_primary').val() === "") {
      return $('#validation_primary_email').removeClass('hidden');
    } else {
      return $('#validation_primary_email').addClass('hidden');
    }
  });

}).call(this);
