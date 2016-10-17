$(document).on('turbolinks:load', function() {
  var tbl_course = $('#course-tbl');
  var dom = "<'row'<'col-sm-4'f><'col-sm-6 filter-status'><'col-sm-2'l>>"
    + "<'row'<'col-sm-12'tr>>" + "<'row'<'col-sm-5'i><'col-sm-7 pull-right'p>>";

  if(tbl_course.length > 0) {
    set_datatable(tbl_course, [2, 5], dom);

    tbl_course.dataTable().columnFilter({
      aoColumns: [
        null,
        null,
        null,
        null,
        null,
        {sSelector: ".filter-status", type:"select",
          values: [
            {value: "0", label: I18n.t("courses.labels.status.init")},
            {value: "1", label: I18n.t("courses.labels.status.progress")},
            {value: "2", label: I18n.t("courses.labels.status.finish")}]},
      ]
    });

    $('#course-tbl_wrapper .select_filter').removeClass('form-control');
  }
  var input_start_date = $('#course_start_date');
  input_start_date.change(function() {
    if ($.trim(input_start_date.val()).length > 0) {
      var start_date = new Date(input_start_date.val());
      start_date.setDate(start_date.getDate() + 60);
      var dd = start_date.getDate();
      var mm = start_date.getMonth() + 1;
      var yyyy = start_date.getFullYear();
      var end_date = yyyy + '/'+ mm + '/'+ dd;
      $('#course_end_date').val(end_date);
    }
  });
});
