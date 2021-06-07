S3 = function(csrfToken) {
  var handlers = [];
  var obj = this;

  var isSuccess = function(xhr) {
    return (xhr.status >= 200 && xhr.status < 300) || xhr.status === 304;
  };

  var formData = function(file, fields) {
    var data = new FormData();

    if (fields) {
      Object.keys(fields).forEach(function(key) {
        data.append(key, fields[key]);
      });
    }

    data.append('file', file);

    return data;
  };

  var emit = function(eventName) {
    for (var list = handlers[eventName], i = 0; list && list[i];) {
        list[i++].apply(obj, list.slice.call(arguments, 1));
    };

    return obj;
  };

  var presignFailure = function(xhr) {
    emit('presign:failure');
    emit('upload:failure');
  };

  var completeUpload = function(completeUrl) {
    var completionXhr = new XMLHttpRequest();

    completionXhr.addEventListener('load', function() {
      if (isSuccess(completionXhr)) {
        emit('upload:success', JSON.parse(completionXhr.response));
      } else {
        emit('upload:failure', completionXhr);
      }
    });

    completionXhr.open('PUT', completeUrl, true);
    completionXhr.setRequestHeader('X-CSRF-Token', csrfToken);
    completionXhr.send();
  };

  // Event Emitter functions
  this.on = function(eventName, handler) {
    (handlers[eventName] = handlers[eventName] || []).push(handler);

    return obj;
  };

  this.upload = function(presignUrl, file) {
    emit('presign:start');
    var presignXhr = new XMLHttpRequest();

    presignXhr.addEventListener('load', function() {
      var presignReqData = JSON.parse(presignXhr.responseText);
      var resourceUrl = presignReqData.resourceUrl;
      emit('presign:complete');

      if (isSuccess(presignXhr)) {
        emit('presign:success');
        var uploadXhr = new XMLHttpRequest();

        uploadXhr.addEventListener('load', function() {
          if (isSuccess(uploadXhr)) {
            completeUpload(resourceUrl)
          } else {
            emit('upload:failure', { message: uploadXhr.response });
          };
        });

        uploadXhr.upload.addEventListener('progress', function(progressEvent) {
          var details = Object.assign(presignReqData, {
            loaded: progressEvent.loaded, total: progressEvent.total
          });
          emit('upload:progress', details);
        });

        uploadXhr.open('POST', presignReqData.url, true);
        uploadXhr.send(formData(file, presignReqData.fields));

        emit('upload:start', presignReqData);
      } else {
        presignFailure();
      };
    });

    presignXhr.addEventListener('error', presignFailure);
    presignXhr.addEventListener('abort', presignFailure);

    presignXhr.open('POST', presignUrl, true);
    presignXhr.setRequestHeader('X-CSRF-Token', csrfToken);
    presignXhr.send();
  };

  this.destroy = function(url) {
    var destroyXhr = new XMLHttpRequest();
    destroyXhr.open('DELETE', url, true);
    destroyXhr.setRequestHeader('X-CSRF-Token', csrfToken);
    destroyXhr.send();
  };
};
