$(document).ready(function() {
  var abSelect = $("#search_which_test");

  abSelect.change(function() {
    if (abSelect.val() == "none") {
      $("#host-wrapper").show();
    } else {
      $("#host-wrapper").hide();
    }
  });

  abSelect.change();
});
