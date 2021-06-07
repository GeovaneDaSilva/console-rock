FilePicker = function() {
  var csrfToken = $('head meta[name="csrf-token"]').attr('content');

  var buildFigure = function($target) {
    $target.append('<figure class="pending"><img/><a class="remove">remove</a><figcaption></figcaption><div class="progress"></div></figure>');
    var $figure = $target.find('figure').last();
    var $img = $figure.find('img').last();
    var $caption = $figure.find('figcaption').last();
    var $progress = $figure.find('.progress').last();

    return { figure: $figure, caption: $caption, img: $img, progress: $progress };
  };

  $(document).on('change', '.file-picker input[type="file"]', function(delegatedEvent) {
    var event = delegatedEvent.originalEvent;
    var $input = $(this);
    var $preview = $($input.attr('data-preview'));
    var $id = $($input.attr('data-id-target'));
    var presignBaseUrl = $input.parent('.file-picker').find('meta[name="presignUrl"]').attr('content');
    var completedUploadCount = 0;

    $('fieldset').attr('disabled', 'disabled'); // Prevent the form from being submitted

    var completedUpload = function(uploadData, domElements) {
      domElements.img.attr('src', uploadData.url);
      domElements.caption.html(uploadData.filename);
      domElements.figure.removeClass('pending');
      domElements.figure.attr('data-resource-url', uploadData.resourceUrl);
      $id.val(uploadData.id)
      completedUploadCount += 1;

      if (completedUploadCount == event.target.files.length) {
        $('fieldset').removeAttr('disabled'); // Allow the form to be submitted
        $input.val('');
      }
    };

    var uploadStarted = function(file, domElements) {
      var imgMimeTypeRegex = /^image\//
      if (imgMimeTypeRegex.test(file.type)) {
        var reader = new FileReader();

        reader.onload = function(ev) {
          domElements.img.attr('src', ev.target.result);
        };

        reader.readAsDataURL(file);
      };

      domElements.caption.html(file.name);

      if ($input.attr('multiple') == undefined) {
        $preview.find('figure:not(.pending)').each(function() {
          var $el = $(this);
          $el.addClass('hide');
          $el.find('a.remove').trigger('click');
        });
      };
    };

    [].forEach.call(event.target.files, function(file) {
      var domElements;
      var filename   = encodeURIComponent(file.name);
      var size       = encodeURIComponent(file.size);
      var mimeType   = encodeURIComponent(file.type)
      var uploader   = new S3(csrfToken);
      var presignUrl = presignBaseUrl +
                        '?filename=' + filename +
                        '&size=' + size +
                        '&mime_type=' + mimeType +
                        '&t=' + Date.now();

      if ($preview.length > 0) {
        domElements = buildFigure($preview);
      } else {
        domElements = buildFigure($('<div>'));
      };

      uploader.on('upload:success', function(uploadData) {
        completedUpload(uploadData, domElements);
        disableButtons(false);
      });

      uploader.on('upload:progress', function(event) {
        var progress = event.loaded / event.total * 100;
        domElements.progress.attr('width', progress + '%');
      });

      uploader.on('upload:failure', function() {
        domElements.figure.addClass('error');
      });

      uploader.on('presign:success', function() {
        uploadStarted(file, domElements);
        disableButtons(true);
      });

      uploader.upload(presignUrl, file);
    });

    var disableButtons = function(disable) {
      Array.from(event.target.closest('form').querySelectorAll('button')).forEach(function(e) { e.disabled = disable; }, disable);
    }
  });
};

FilePicker();
