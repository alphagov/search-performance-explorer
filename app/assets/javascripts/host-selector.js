$(document).ready(function() {
  var abSelect = document.getElementById("AB_select");
  var hostWrapper = document.getElementById("host-wrapper");
  abSelect.addEventListener("change", showForm);

  function showForm() {
    if (abSelect.value == "search_match_length") {
      hostWrapper.style.display = "none";
    } else {
      hostWrapper.style.display = "block";
    }
  }

  showForm()
});
