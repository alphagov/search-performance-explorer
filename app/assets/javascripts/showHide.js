$(document).ready(function() {
  var showHideButton = document.getElementById("show-hide-search");
  var newSearch = document.getElementById('new-search')

  showHideButton.addEventListener("click", showHideSearch);

  function showHideSearch() {
    if (newSearch.style.display == "none") {
      newSearch.style.display = "block";
      showHideButton.innerHTML = "Hide Search"
    } else {
      newSearch.style.display = "none"
      showHideButton.innerHTML = "Show Search"
    }
  }

  showHideSearch()
});
