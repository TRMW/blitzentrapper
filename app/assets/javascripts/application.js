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

  $('.instagram-media').each(function(embed) {
    $(this).parent('.home__blog-post__video').addClass('home__blog-post__video--instagram');
  });
});


// Tumblr functions to render video uploads

if(!Tumblr){var Tumblr={}}Tumblr.flashVersion=function(){if(navigator.plugins&&navigator.plugins.length>0){var a=navigator.mimeTypes;if(a&&a["application/x-shockwave-flash"]&&a["application/x-shockwave-flash"].enabledPlugin&&a["application/x-shockwave-flash"].enabledPlugin.description){return parseInt(a["application/x-shockwave-flash"].enabledPlugin.description.split(" ")[2].split(".")[0],10)}}else{if(navigator.appVersion.indexOf("Mac")==-1&&window.execScript){try{var c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");var b=c.GetVariable("$version");return b.split(",")[0].split(" ")[1]}catch(d){}return 0}}};Tumblr.replaceIfFlash=function(b,a,c){if(Tumblr.flashVersion()>=b){document.getElementById(a).innerHTML=c}};Tumblr.renderVideo=function(c,g,e,a,b){var d=navigator.userAgent.toLowerCase();var f=(d.indexOf("iphone")!=-1);if(f){document.getElementById(c).innerHTML='<object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" width="'+e+'" height="'+a+'" codebase="http://www.apple.com/qtactivex/qtplugin.cab"><param name="src" value="'+g+'"><param name="qtsrc" value="'+g+'"><param name="autoplay" value="false"><embed src="'+g+'" qtsrc="'+g+'" width="'+e+'" height="'+a+'" pluginspage="http://www.apple.com/quicktime/"></embed></object>'}else{replaceIfFlash(10,c,'<embed type="application/x-shockwave-flash" src="http://assets.tumblr.com/swf/video_player.swf?22" bgcolor="#000000" quality="high" class="video_player" allowfullscreen="true" height="'+a+'" width="'+e+'" flashvars="file='+encodeURIComponent(g)+(b?"&amp;"+b:"")+'"></embed>')}};function flashVersion(){return Tumblr.flashVersion()}function renderVideo(c,e,d,a,b){Tumblr.renderVideo(c,e,d,a,b)}function replaceIfFlash(b,a,c){Tumblr.replaceIfFlash(b,a,c)};

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
