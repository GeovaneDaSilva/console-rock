UploadAndSubmit = function() {
  $(document).on('change', '.upload-and-submit input[type="file"]', function(ev) {
    var event = ev.originalEvent;
    var $input = $(this);
    var $form = $input.parents("form").first();
    var $fieldset = $form.find('fieldset');
    var csrfToken = $('head meta[name="csrf-token"]').attr('content');
    var presignBaseUrl = appendDataUploadValues($form.find('meta[name="presignUrl"]').attr('content'));
    var completedUploadCount = 0;

    $fieldset.attr('disabled', '');

    function appendDataUploadValues(url) {
      return url + '?' + $form.serialize();
    }

    [].forEach.call(event.target.files, function(file) {
      var filename   = encodeURIComponent(file.name);
      var size       = encodeURIComponent(file.size);
      var mimeType   = encodeURIComponent(file.type)
      var uploader   = new S3(csrfToken);
      var presignUrl = presignBaseUrl +
                        '&filename=' + filename +
                        '&size=' + size +
                        '&mime_type=' + mimeType +
                        '&t=' + Date.now();

      presignUrl = appendDataUploadValues(presignUrl);

      uploader.on('upload:success', function(uploadData) {
        completedUploadCount += 1;

        if (completedUploadCount == event.target.files.length) {
          $form.submit();
        };
      });


      uploader.on('upload:failure', function() {
        alert('Error uploading file');
      });

      uploader.upload(presignUrl, file);
    });
 })
};

UploadAndSubmit();
