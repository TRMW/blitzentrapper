//= require jquery
//= require jquery_ujs
//= require trix
//= require_self
//= require_tree .

$(document).ready(function(){
  // ajax search functionality
  $('.live-search').on('keyup', function() {
    var el = $(this),
      action = el.data('action'),
      target = el.data('target');
    $.post(
        action,
        el.serialize(),
        function(data) { $(target).html(data); },
        'html'
      );
  });
});


// Trix attachment upoad
// Copied from the example here:
// https://github.com/basecamp/trix/blob/fbb2913ad591b5fc49b485c22767d90afb243cd9/README.md#storing-attached-files

(function() {
  var createStorageKey, host, uploadAttachment;

  document.addEventListener('trix-attachment-add', function(event) {
    var attachment;
    attachment = event.attachment;
    if (attachment.file) {
      return uploadAttachment(attachment);
    }
  });

  if (window.location.hostname === 'www.blitzentrapper.net') {
    // production
    host = 'http://files.blitzentrapper.net';
  } else {
    // staging or dev
    host = 'http://d219p4uhr2c78m.cloudfront.net';
  }

  uploadAttachment = function(attachment) {
    var file, form, key, xhr;
    file = attachment.file;
    key = createStorageKey(file);
    form = new FormData;
    form.append('key', key);
    form.append('Content-Type', file.type);
    form.append('file', file);
    xhr = new XMLHttpRequest;
    xhr.open('POST', host, true);
    xhr.upload.onprogress = function(event) {
      var progress;
      progress = event.loaded / event.total * 100;
      return attachment.setUploadProgress(progress);
    };
    xhr.onload = function() {
      var href, url;
      if (xhr.status === 204) {
        url = href = host + '/' + key;
        return attachment.setAttributes({
          url: url,
          href: href
        });
      }
    };
    return xhr.send(form);
  };

  createStorageKey = function(file) {
    var date, day, time;
    date = new Date();
    day = date.toISOString().slice(0, 10);
    time = date.getTime();
    return 'post-uploads/' + day + '/' + time + '-' + file.name;
  };

}).call(this);
