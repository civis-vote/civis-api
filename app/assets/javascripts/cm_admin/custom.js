document.addEventListener("turbo:load", function () {
  function updateConditionalQuestionOptions() {
    let questionId = null,
      responseRoundId = null;

    if (location.pathname.endsWith("/edit")) {
      questionId = location.pathname.split("/")[3];
    } else if (location.pathname.endsWith("/new")) {
      const urlParams = new URLSearchParams(location.search);
      if (urlParams.get("associated_class") === "response_round") {
        responseRoundId = urlParams.get("associated_id");
      }
    }

    if (!questionId && !responseRoundId) {
      return;
    }

    const url = "/cm_admin/questions/response_round_questions";
    const params = {
      question_id: questionId ?? "",
      response_round_id: responseRoundId ?? "",
    };
    const queryParams = new URLSearchParams(params).toString();

    $('[data-field-name="conditional_question_id"]').select2({
      theme: "bootstrap-5",
      ajax: {
        url: url + "?" + queryParams,
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
            results: [{ id: "", text: "Select Conditional Question" }].concat(
              data.results
            ),
          };
        },
      },
      minimumInputLength: 0,
    });
  }

  $(document).on(
    "click",
    '.nested-table-footer [data-association="sub_question"]',
    function () {
      updateConditionalQuestionOptions();
    }
  );
  updateConditionalQuestionOptions();

  $(document).on("change", '[data-field-name="question_type"]', function () {
    updateOptionsVisibility();
    updateSelectedOptionLimitVisibility();
  });
  function updateOptionsVisibility() {
    const questionType = $("[data-cm-id='question_type']").val();
    if (questionType === "" || questionType === "long_text") {
      const nearestCol = $("[data-section-id='options']").closest(".col");
      if (nearestCol.length > 0) {
        nearestCol.hide();
      }
    } else {
      const nearestCol = $("[data-section-id='options']").closest(".col");
      if (nearestCol.length > 0) {
        nearestCol.show();
      }
    }
  }
  function updateSelectedOptionLimitVisibility() {
    const questionType = $("[data-cm-id='question_type']").val();
    if (questionType === "checkbox" || questionType === "multiple_choice") {
      $("[data-cm-id='selected_options_limit']")
        .closest(".row")
        .removeAttr("hidden", "true");
    } else {
      $("[data-cm-id='selected_options_limit']")
        .closest(".row")
        .attr("hidden", "true");
    }
  }
  updateOptionsVisibility();
  updateSelectedOptionLimitVisibility();
});
