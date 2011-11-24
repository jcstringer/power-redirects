class RedirectWorker < SimpleWorker::Base
  attr_accessor :input, :token, :shop
  merge_gem "shopify_api"
  merge_gem "shopify_app"
  
  def run
    create_session!
    numadded = 0
    myerrors = ""
    input.each do |line|
      urls   = line.split(/\s+/)
      if urls.size != 2
        myerrors += "#{line}<br />Data not in proper format<br />" 
      elsif urls[0].length < 2
        myerrors += "#{line}<br />Path must be at least 2 characters long<br />"
      elsif urls[0] =~ /\"|\'/ || urls[1] =~ /\"|\'/
         myerrors += "#{line}<br />Path and Target cannot contain double or single quote characters<br />"
      else
        r = ShopifyAPI::Redirect.new(:path => create_path(urls[0]), :target => create_path(urls[1]))
        if !r.save
          myerrors += "#{line}:<br />"
          r.errors.each_full {|msg| myerrors += "#{msg}<br />"}
        else
          numadded += 1
        end
      end  
    end
  end
  
  private 
  
  def create_session!
    ShopifyAPI::Base.site = "Site goes here"
  end  
  
  def create_path(surl)
    return "" if surl.nil?
    surl.strip!
    surl.gsub!(/^(?:[^\/]+:(\/)+)?(\w+\.)+(\w)+/, '')
    surl = "/" + surl if surl.slice(0..0) != "/"
    surl
  end

end