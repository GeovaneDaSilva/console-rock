$(document).on('click', 'figure a.remove', function(delegatedEvent) {
  if (delegatedEvent.originalEvent) {
    var event = delegatedEvent.originalEvent;
  } else {
    var event = delegatedEvent;
  }

  var $figure = $(event.target).parents('figure');
  var resourceUrl = $figure.attr('data-resource-url');
  var csrfToken = $('head meta[name="csrf-token"]').attr('content');
  var deleteXhr = new XMLHttpRequest();

  $figure.hide();

  deleteXhr.addEventListener('load', function() {
    $figure.remove();
  });

  deleteXhr.open('DELETE', resourceUrl, true);
  deleteXhr.setRequestHeader('X-CSRF-Token', csrfToken);
  deleteXhr.send();
});
