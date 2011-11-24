class RedirectsController < ApplicationController
  around_filter :shopify_session
  respond_to :js, :only => :get_targets
  
  TARGET_TYPES = [
    ["Page", "page"],
    ["Custom Collection", "custom_collection"],
    ["Smart Collection", "smart_collection"],
    ["Products", "products"],
    ["Homepage", "homepage"],
    ["Custom URL", "custom_url"]
  ]
  
  def index
    @redirects = Redirect.find(:all, :limit => 100).count
  end  
  
  def show
    @redirect = Redirect.find(params[:id])
    if @redirect
      @shop = Shop.current
      pages = Page.find(:all, :params => {:published_status => "published", :limit => 250})
      smart_collections = SmartCollection.find(:all, :params => {:limit => 250})
      page_array = pages.inject([]) {|memo,val| memo << [val.handle,"/pages/#{val.handle}"]}
      smart_collection_array = smart_collections.inject([]) {|memo,val| memo << [val.handle,"/collections/#{val.handle}"]}
      @grouped_options = {"Home" => ["/"], "Pages" => page_array, "Smart Collections" => smart_collection_array}
      render :template => 'redirects/new'
    else
      flash[:error] = "You are attempting to update a redirect that no longer exists."
      redirect_to :action => :index
    end  
  end
  
  def new
    @shop = Shop.current
    @product = Product.find(params[:id], :limit => 1)
    pages = Page.find(:all, :params => {:published_status => "published", :limit => 250})
    smart_collections = SmartCollection.find(:all, :params => {:limit => 250})
    page_array = pages.inject([]) {|memo,val| memo << [val.title,"/pages/#{val.handle}"]}
    smart_collection_array = smart_collections.inject([]) {|memo,val| memo << [val.title,"/collections/#{val.handle}"]}
    #products = Product.find(:all, :params => {:published_status => "published", :limit => 250})
    #products_array = products.inject([]) {|memo,val| memo << [val.title,"/products/#{val.handle}"]}
    @grouped_options = {"Home" => ["/"], "Pages" => page_array, "Smart Collections" => smart_collection_array}
    @redirect = Redirect.new(:path => "/products/#{@product.handle}", :target => nil)
    @target_types = TARGET_TYPES
  end  
  
  def create
    @redirect = Redirect.new(params[:redirect])
    if @redirect.save
      flash[:notice] = "Your redirect was saved."
      redirect_to :action => :show, :id => @redirect.id
    else
      flash[:error] = "There was a problem creating your redirect. There is likely already a redirect for this url."
      redirect_to :back
    end   
  end  
  
  def update
    @redirect = Redirect.find(params[:id])
    @redirect.target = params[:redirect][:target] if @redirect
    if @redirect && @redirect.save
      flash[:notice] = "Your redirect was updated."
      redirect_to :action => :show, :id => @redirect.id
    else
      if params[:redirect][:target].blank? 
        flash[:error] = "Update failed, you must select a valid page to redirect to."
      elsif !@redirect
        flash[:error] = "You are attempting to update a redirect that no longer exists."
      else  
        flash[:error] = "There was a problem updating your redirect. This is likely because there is already a redirect created from the URL you entered, so saving would create a double redirect."
      end
      redirect_to :back
    end   
  end
  
  def create_bulk
    worker = RedirectWorker.new
    worker.input = params[:redirects].split(/[\r\n]+/).slice(0..249)
    worker.token = session[:shopify].token
    worker.shop  = current_shop.url
    RAILS_ENV == "development" ? worker.run_local : worker.queue
    flash[:notice] = RAILS_ENV == "development" ? "" : "Worker id is #{worker.status.inspect}. "
    flash[:notice] += "#{worker.input.size} redirects were queued for creation. Please be patient as this process may take as long as 30 mins depending on the queue size."
    redirect_to :action => :bulk
  end  
  
  def get_targets
    #type = params[:type]
    #if type == "page"
      pages = Page.find(:all, :params => {:published_status => "published", :limit => 250})
      @options = pages.inject([]) {|memo,val| memo << [val.title,"/pages/#{val.handle}"]}
    #end
    @redirect = Redirect.new(:path => "/products/foo", :target => nil)
    respond_with(@options, @redirect)
  end  
  
end
