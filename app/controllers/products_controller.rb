class ProductsController < ApplicationController
  def category
    topspin = Rails.cache.fetch("topspin_#{params[:category]}") do
      logger.info("****** Fetching #{params[:category]} category from Topspin. ******")
      HTTParty.get("http://app.topspin.net/api/v2/store/2478/#{params[:category]}/0/100",
                :format => :json,
                :basic_auth => {
                  :username => 'tina@blitzentrapper.net',
                  :password => 'db9686d0474b012d7904001e0bd54540'
                }).to_hash;
    end
    @products = topspin['offers']
    @store_config = topspin['store_configuration']
    if @store_config['featured_offer_id'] != -1 # it's -1 if set to off
      logger.info("****** Fetching featured item from Topspin. ******")
      @feature = HTTParty.get("http://app.topspin.net/api/v2/store/detail/#{@store_config['featured_offer_id']}",
                  :format => :json,
                  :basic_auth => {
                    :username => 'tina@blitzentrapper.net',
                    :password => 'db9686d0474b012d7904001e0bd54540'
                  });
      @show_feature = params[:category] == 'new' && @feature['message'] != "Couldn't find Widget with ID=#{@store_config['featured_offer_id']}"
    end
    @title = (params[:category] == 'cds' ? 'CDs' : params[:category].titleize) + ' - Store'
    render 'index'
  end

  def show
    @product = HTTParty.get("http://app.topspin.net/api/v2/store/detail/#{params[:id]}",
                :format => :json,
                :basic_auth => {
                  :username => 'tina@blitzentrapper.net',
                  :password => 'db9686d0474b012d7904001e0bd54540'
                });
    @store_config = @product['store_configuration']
  end

  def search
    products = Rails.cache.fetch("topspin_all") do
      logger.info("****** Fetching all items from Topspin (for search). ******")
      HTTParty.get("http://app.topspin.net/api/v2/store/2478/ts_all_products/0/100",
        :format => :json,
        :basic_auth => {
          :username => 'tina@blitzentrapper.net',
          :password => 'db9686d0474b012d7904001e0bd54540'
        })['offers'];
    end
    @results = products.find_all { |product| product['name'].match(/#{params[:query]}/i) }
    render 'search', :layout => false
  end

end
