require 'csv'

class ProductsController < ApplicationController
  rescue_from URI::InvalidURIError, with: :render_404

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
    if @product.code == 404
      render_404
    else
      @store_config = @product['store_configuration']
    end
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

  def export
    offers = HTTParty.get("http://app.topspin.net/api/v2/store/2478/ts_all_products/0/100",
               :format => :json,
               :basic_auth => {
                 :username => 'tina@blitzentrapper.net',
                 :password => 'db9686d0474b012d7904001e0bd54540'
             })['offers']

    respond_to do |format|
      format.csv { send_data generate_csv(offers) }
    end
  end

  def generate_csv(offers)
    CSV.generate do |csv|
      offers.each do |offer|
        details = HTTParty.get("http://app.topspin.net/api/v2/store/detail/#{offer['id']}",
                   :format => :json,
                   :basic_auth => {
                     :username => 'tina@blitzentrapper.net',
                     :password => 'db9686d0474b012d7904001e0bd54540'
                   })

        product = details['campaign']['product']

        # create a new item for each image, based on
        # https://docs.shopify.com/support/your-store/products/how-do-i-add-multiple-images-to-products-in-csv
        images = product['images']

        if product['type'] == 'apparel'
          sizes = product['attributes'].try(:[], 'Size')
          if sizes
            sizes.each do |size, i|
              csv << generate_csv_row_from_details(details, size, images[0])
            end
          else
            images.each_with_index do |image, i|
              if i == 0
                csv << generate_csv_row_from_details(details, false, image)
              else
                csv << generate_additional_image_row(details['id'], image['source_url'])
              end
            end
          end
        else
          csv << generate_csv_row_from_details(details, false, images[0])
        end
      end
    end
  end

  def generate_csv_row_from_details(details, size, image)
    csv_row = {}
    product = details['campaign']['product']
    csv_row['description'] = details['description']
    csv_row['price'] = details['price']
    csv_row['source_image_url'] = image.with_indifferent_access['source_url']
    if ['cd', 'vinyl', 'package'].include? product['type']
      csv_row['type'] = 'Music'
      name = details['name']
      ['Furr',
        'Wild Mountain Nation',
        'Field Rexx',
        'Blitzen Trapper',
        'Cool Love #1',
        'Black River Killer',
        'VII',
        'American Goldwing',
        'Destroyer of the Void'
      ].each do |title|
        if name.match(title)
          csv_row['id'] = title.parameterize
          csv_row['name'] = title
          csv_row['option1_name'] = 'Format'
          csv_row['option1_value'] = name.gsub(title, '').strip
        end
      end
    else
      csv_row['type'] = product['type'].titlecase
      csv_row['id'] = details['id']
      csv_row['name'] = details['name']
      if size
        csv_row['option1_name'] = 'Size'
        csv_row['option1_value'] = size
      else
        csv_row['option1_name'] = 'Title'
        csv_row['option1_value'] = '---'
      end
    end
    csv_row.values
  end

  def generate_additional_image_row(id, image_url)
    csv_row = {}
    csv_row['description'] = '---'
    csv_row['price'] = '---'
    csv_row['source_image_url'] = image_url
    csv_row['type'] = '---'
    csv_row['id'] = id
    csv_row['name'] = '---'
    csv_row['option1_name'] = '---'
    csv_row['option1_value'] = '---'
    csv_row.values
  end
end
