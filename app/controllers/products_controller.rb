class ProductsController < ApplicationController
	
	def category
		response = HTTParty.get("http://app.topspin.net/api/v2/store/2478/#{params[:category]}/0/100", 
								:basic_auth => {
									:username => 'sara@blitzentrapper.net',
									:password => 'db9686d0474b012d7904001e0bd54540'
								});
		@products = response['offers']
		@store_config = response['store_configuration']
		if @store_config['featured_offer_id'] != -1 # it's -1 if set to off
			@feature = HTTParty.get("http://app.topspin.net/api/v2/store/detail/#{@store_config['featured_offer_id']}", 
									:basic_auth => {
										:username => 'sara@blitzentrapper.net',
										:password => 'db9686d0474b012d7904001e0bd54540'
									});
			@show_feature = params[:category] == 'new' && @feature['message'] != "Couldn't find Widget with ID=#{@store_config['featured_offer_id']}"
		end
		
		if params[:category] == 'cds'
			@title = 'CDs - Store'
		else
			@title = params[:category].titleize + ' - Store'
		end
		
		render 'index'
	end
	
	def show
		@product = HTTParty.get("http://app.topspin.net/api/v2/store/detail/#{params[:id]}", 
								:basic_auth => {
									:username => 'sara@blitzentrapper.net',
									:password => 'db9686d0474b012d7904001e0bd54540'
								});
		@store_config = @product['store_configuration']
	end
	
	def search
		response = HTTParty.get("http://app.topspin.net/api/v2/store/2478/ts_all_products/0/100", 
								:basic_auth => {
									:username => 'sara@blitzentrapper.net',
									:password => 'db9686d0474b012d7904001e0bd54540'
								});
		products = response['offers']
		@results = []
		for product in products do
			if product['name'].match(/#{params[:query]}/i)
				@results << product
			end
		end
		render 'search', :layout => false
	end

end
