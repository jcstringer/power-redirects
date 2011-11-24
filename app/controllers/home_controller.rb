class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index
    # get 3 products
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 3})

    # get latest 3 orders
    @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
    
    @redirects = ShopifyAPI::Redirect.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
  end
  
  def create_redirect
    @product = ShopifyAPI::Product.find(params[:id], :limit => 1)
    pages = ShopifyAPI::Page.find(:all, :conditions => {:published_status => "published"})
    smart_collections = ShopifyAPI::SmartCollection.find(:all)
    page_array = pages.inject([]) {|memo,val| memo << [val.handle,"/pages/#{val.handle}"]}
    smart_collection_array = smart_collections.inject([]) {|memo,val| memo << [val.handle,"/collections/#{val.handle}"]}
    @grouped_options = {"Pages" => page_array,"Smart Collections" => smart_collection_array}
    @redirect = ShopifyAPI::Redirect.new(:path => "/products/#{@product.handle}", :target => nil)
  end
  
  def save_redirect
    
  end  
    
  
end