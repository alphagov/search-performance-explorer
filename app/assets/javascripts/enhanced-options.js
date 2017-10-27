$(document).ready(function() {
  $('.search-info-level').change(function () {
    if ($(this).attr('id') === 'search_info_enhanced') {
      $('#enhanced-checkbox').show();
    } else {
      $('#enhanced-checkbox').hide();
    }
  })
  $('.search-info-level:checked').change();
});
