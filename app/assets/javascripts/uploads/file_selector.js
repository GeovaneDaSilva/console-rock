window.uploads = function () {
  var csrfToken = document.querySelector('head meta[name="csrf-token"]').getAttribute('content');
  var presignBaseUrl = document.querySelector('meta[name="presignUrl"]').getAttribute('content');

  function bubbleEvent(el, key, detail) {
    var event = new CustomEvent(key, {
      bubbles: true,
      detail: detail
    });
    el.dispatchEvent(event);
  }

  ;

  function uploadFiles(ev) {
    var completedUploadCount = 0;
    var input = ev.target;
    var files = input.files;
    bubbleEvent(input, 'uploads:start', {});
    [].forEach.call(files, function (file) {
      var filename = encodeURIComponent(file.name);
      var size = encodeURIComponent(file.size);
      var mimeType = encodeURIComponent(file.type);
      var uploader = new S3(csrfToken);
      var presignUrl = presignBaseUrl + '?filename=' + filename + '&size=' + size + '&mime_type=' + mimeType + '&t=' + Date.now();
      uploader.on('upload:start', function (presignData) {
        bubbleEvent(input, 'upload:start', {
          file: file,
          data: presignData
        });
      });
      uploader.on('upload:progress', function (progressData) {
        bubbleEvent(input, 'upload:progress', {
          file: file,
          data: progressData
        });
      });
      uploader.on('upload:success', function (uploadData) {
        bubbleEvent(input, 'upload:success', {
          file: file,
          data: uploadData
        });
        completedUploadCount += 1;

        if (completedUploadCount == files.length) {
          bubbleEvent(input, 'uploads:complete');
          input.value = null;
        }

        ;
      });
      uploader.on('upload:failure', function () {
        bubbleEvent(input, 'upload:failure', {
          file: file
        });
      });
      uploader.upload(presignUrl, file);
    });
  }

  ;
  [].forEach.call(document.querySelectorAll('[type="file"][data-upload]:not([data-upload-init])'), function (uploader) {
    uploader.addEventListener('change', uploadFiles);
    uploader.setAttribute('data-upload-init', true);
  });
};

window.fileUploads = function (input, gallery) {
  input.addEventListener('uploads:start', function () {
    input.parentElement.setAttribute('disabled', true);
    var submitEl = input.form.querySelector('input[type="submit"]');
    if (submitEl !== null) submitEl.setAttribute('disabled', true);
  });
  input.addEventListener('upload:start', function (ev) {
    var figure = document.createRange().createContextualFragment("<figure id=\"".concat(ev.detail.data.id, "\"><figcaption>").concat(ev.detail.file.name, " <a href=\"").concat(ev.detail.data.resourceUrl, "\" data-remote=\"true\" data-method=\"delete\" hidden><i></i>Remove</a></figcaption><progress value=\"0\" max=\"100\"></progress><input type=\"hidden\" name=\"upload_ids[]\" value=\"").concat(ev.detail.data.id, "\"/></figure>"));
    gallery.appendChild(figure);
  });
  input.addEventListener('upload:progress', function (progressEv) {
    var figure = document.getElementById(progressEv.detail.data.id);
    var progress = figure.querySelector('progress');
    var progressPercentage = progressEv.detail.data.loaded / progressEv.detail.data.total * 100;
    progress.setAttribute('value', progressPercentage);
  });
  input.addEventListener('upload:success', function (successEv) {
    var figure = document.getElementById(successEv.detail.data.id);
    var remove = figure.querySelector('a');
    remove.removeAttribute('hidden');
    remove.addEventListener('click', function () {
      figure.setAttribute('hidden', true);
      var event = new CustomEvent('upload:removed', {
        bubbles: true,
        detail: successEv.detail
      });
      input.dispatchEvent(event);
    });
  });
  input.addEventListener('uploads:complete', function () {
    input.parentElement.removeAttribute('disabled');
    input.form.querySelector('input[type="submit"]').removeAttribute('disabled');
  });
  input.addEventListener('upload:failure', function (ev) {
    input.parentElement.removeAttribute('disabled');
    var submitEl = input.form.querySelector('input[type="submit"]');
    if (submitEl !== null) submitEl.removeAttribute('disabled');
    alert('Upload failed!');
  });
};
