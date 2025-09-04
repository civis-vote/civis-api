document.addEventListener("turbo:load", function () {
  function updateConditionalQuestionOptions() {
    const conditionalQuestionId = $(
      '[data-field-name="conditional_question_id"]'
    ).val();
    if (!conditionalQuestionId) return;

    $('[data-field-name="conditional_question_option_id"]')
      .val(null)
      .trigger("change");

    $('[data-field-name="conditional_question_option_id"]').select2({
      theme: "bootstrap-5",
      ajax: {
        url:
          "/cm_admin/questions/conditional_question_options?question_id=" +
          conditionalQuestionId,
        type: "GET",
        dataType: "json",
        data: function (params) {
          var query = {
            search: params.term,
          };
          return query;
        },
        processResults: (data, params) => {
          return {
            results: data.results,
          };
        },
      },
      minimumInputLength: 0,
    });
  }

  $('[data-field-name="conditional_question_id"]').on("change", function () {
    updateConditionalQuestionOptions();
  });
});
