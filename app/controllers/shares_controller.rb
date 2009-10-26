class SharesController < ApplicationController
  before_filter :non_public_role_required
  
  def new
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new
  end
  
  def create
    @document = current_user.documents.find(params[:document_id])
    @audience = Audience.new(params[:audience])
    @document.targets.create! :audience => @audience, :creator => current_user
    if params[:document]
      if params[:document][:audience_ids]
        params[:document][:audience_ids].each do |id|
          @document.targets.create! :audience_id => id, :creator => current_user
        end
      end
      @document.channel_ids += params[:document][:channel_ids] if params[:document][:channel_ids]
      @document.save!
    end
    flash[:notice] = 'Successfully shared the document'
    redirect_to documents_path
  end

end
