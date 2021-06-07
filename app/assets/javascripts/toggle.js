$(document).on('click', 'a[data-toggler="hidden"]', function(ev) {
  ev.preventDefault();

  $el = $($(this).attr('href'));

  if ($el.attr('hidden')) {
    $el.removeAttr('hidden')
  } else {
    $el.attr('hidden', true)
  }
})
