$(document).ready(function() {
  var basicRadio = document.getElementById('info_basic')
  var enhancedRadio = document.getElementById('info_enhanced');
  var enhancedCheckbox = document.getElementById('enhanced-checkbox');
  enhancedRadio.addEventListener("change", enhancedOptions);
  basicRadio.addEventListener("change", enhancedOptions);


  function enhancedOptions() {
    if (enhancedRadio.checked == true) {
      enhancedCheckbox.style.display = 'block';
    } else {
      enhancedCheckbox.style.display = 'none';
    }
  }
  enhancedOptions()
});
