$(document).on('change', 'form[data-onchangesubmitpath] .reload-on-change', function(ev) {
  var $el = $(this);
  var $form = $el.closest('form[data-onchangesubmitpath]');

  $form.attr('action', $form.attr('data-onchangesubmitpath'));
  $form.attr('method', 'get');
  $form.submit();
});
