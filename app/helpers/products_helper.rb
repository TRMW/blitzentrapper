module ProductsHelper
	def get_v1_player(v2_embed)
		player_id = v2_embed[/\d{1,5}/]
		"<div class=\"topspin-widget topspin-widget-bundle-widget\"> 
		<object type=\"application/x-shockwave-flash\" width=\"300\" height=\"198\" id=\"TSWidget#{player_id}\" data=\"http://cdn.topspin.net/widgets/bundle/swf/TSBundleWidget.swf\"> 
		<param value=\"always\" name=\"allowScriptAccess\" /> 
		<param name=\"allowfullscreen\" value=\"true\" /> 
		<param name=\"quality\" value=\"high\" /> 
		<param name=\"movie\" value=\"http://cdn.topspin.net/widgets/bundle/swf/TSBundleWidget.swf\" /> 
		<param name=\"flashvars\" value=\"widget_id=http://cdn.topspin.net/api/v1/artist/2478/bundle_widget/#{player_id}&amp;theme=white&amp;highlightColor=0xBD8B00&amp;displayCTAButton=false\" /> 
		<param name=\"wmode\" value=\"transparent\" /> 
		</object> 
		</div>"
	end
	
	def render_product_attributes(product)
		if product['type'] == 'apparel'
			@response = render :partial => 'shirt', :object => product
		elsif(product['media'] && (product['media'][0]['type'] == 'track'))
			@response = render :partial => 'tracks', :object => product['media']
		elsif product['type'] == 'package'
			for child_product in product['media']
				render_product_attributes(child_product)
			end
		end
		@response
	end
end
