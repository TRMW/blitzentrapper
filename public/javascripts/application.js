$(document).ready(function(){

	// ajax search functionality
  $(".live-search").change(function() {
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

	// product gallery setup
	$('.item-detail-image-medium').fancybox();
	
	$('.item-detail-image-small').click(function(){
		var target = $(this).data('target-image');
		$('.item-detail-image-main').removeClass('item-detail-image-main');
		$(target).addClass('item-detail-image-main');
		return false;
	});
	
	$('.item-detail-image-main').hover(
		function(){
			$(this).append('<span class="item-image-zoom">View Larger</span>');
		},
		function() {
	  	$(this).find('.item-image-zoom').remove();
	  }
  );

});

// Tumblr functions to render video uploads
if(!Tumblr){var Tumblr={}}Tumblr.flashVersion=function(){if(navigator.plugins&&navigator.plugins.length>0){var a=navigator.mimeTypes;if(a&&a["application/x-shockwave-flash"]&&a["application/x-shockwave-flash"].enabledPlugin&&a["application/x-shockwave-flash"].enabledPlugin.description){return parseInt(a["application/x-shockwave-flash"].enabledPlugin.description.split(" ")[2].split(".")[0],10)}}else{if(navigator.appVersion.indexOf("Mac")==-1&&window.execScript){try{var c=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");var b=c.GetVariable("$version");return b.split(",")[0].split(" ")[1]}catch(d){}return 0}}};Tumblr.replaceIfFlash=function(b,a,c){if(Tumblr.flashVersion()>=b){document.getElementById(a).innerHTML=c}};Tumblr.renderVideo=function(c,g,e,a,b){var d=navigator.userAgent.toLowerCase();var f=(d.indexOf("iphone")!=-1);if(f){document.getElementById(c).innerHTML='<object classid="clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B" width="'+e+'" height="'+a+'" codebase="http://www.apple.com/qtactivex/qtplugin.cab"><param name="src" value="'+g+'"><param name="qtsrc" value="'+g+'"><param name="autoplay" value="false"><embed src="'+g+'" qtsrc="'+g+'" width="'+e+'" height="'+a+'" pluginspage="http://www.apple.com/quicktime/"></embed></object>'}else{replaceIfFlash(10,c,'<embed type="application/x-shockwave-flash" src="http://assets.tumblr.com/swf/video_player.swf?22" bgcolor="#000000" quality="high" class="video_player" allowfullscreen="true" height="'+a+'" width="'+e+'" flashvars="file='+encodeURIComponent(g)+(b?"&amp;"+b:"")+'"></embed>')}};function flashVersion(){return Tumblr.flashVersion()}function renderVideo(c,e,d,a,b){Tumblr.renderVideo(c,e,d,a,b)}function replaceIfFlash(b,a,c){Tumblr.replaceIfFlash(b,a,c)};