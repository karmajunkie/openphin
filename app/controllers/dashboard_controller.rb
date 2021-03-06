class DashboardController < ApplicationController  
  skip_before_filter :login_required, :only => [:about]
  require 'feedzirra'
  

  def index
    DashboardController.app_toolbar "application"
	  @articles = Article.recent
    feed_urls = [
      "http://www.nhc.noaa.gov/gtwo.xml",
      "http://www.nhc.noaa.gov/nhc_at2.xml"
     ]
    @entries = []
    begin   
      feed_urls.each do |url|
        @entries += Feedzirra::Feed.fetch_and_parse(url).entries
      end
      @entries = @entries.sort{|a,b| b.published <=> a.published}[0..9]
    rescue
      @entries = nil  
    end
  end

  def about
    DashboardController.app_toolbar "application"
  end

  def hud
    DashboardController.app_toolbar "han"
    @user = current_user
    @alerts = present_collection(current_user.recent_alerts.size > 0 ? current_user.recent_alerts.paginate(:page => params[:page], :per_page => 10) : [Alert.default_alert].paginate(:page => 1))
  end
  
	def faqs
    DashboardController.app_toolbar "faqs"
	end
end
