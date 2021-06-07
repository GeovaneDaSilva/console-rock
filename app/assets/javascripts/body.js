//= require aside
//= require tooltip
//= require toastr
//= require search
//= require panels
//= require collapsable
//= require anchored_tabs
//= require_self
// Handled tab navigation
$(function (e) {
  var id = document.URL.split("#")[1];

  if (id != undefined) {
    $('[data-toggle="tab"][href="#' + id + '"]').tab('show');
  } else {
    $('[data-toggle="tab"]').first().tab('show');
  }

  ;
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    window.history.pushState("", document.title, window.location.pathname);
  });
});
