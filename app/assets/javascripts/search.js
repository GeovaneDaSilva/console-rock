var $form = $('#search-form');

$('#search-input').autocomplete({
  source: function(request, response) {
    $.ajax({
      url: $form.attr('action'),
      data: $form.serialize(),
      dataType: "script"
    }).done(function (data, status) {
      response(JSON.parse(data));
    });
  },
  select: function() {
    $form.submit();
  },
  focus: function(event, ui) {
    var $ui = $(event.currentTarget);
    $ui.children('.focus').removeClass('focus');
    $ui.find('.ui-state-active').parent().addClass('focus');
  }
})
