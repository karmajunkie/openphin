class ForumsController < ApplicationController

  before_filter :non_public_role_required
  app_toolbar "forums"

  def index
    @forums = Forum.paginate_for(:all,current_user,params[:page] || 1)
  end
  
  def show
    @forum = Forum.find_for(params[:id],current_user)
  end
  
  def new
    @forum = Forum.new
  end
  
  def create
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = "Forum was successfully created."
      redirect_to forums_url
    else
      render :action => 'new'
    end
  end
  
  def edit
      @forum = Forum.find_for(params[:id],current_user)
    end

  def update
    @forum = Forum.find_for(params[:id],current_user)
    merge_if(params[:forum][:audience_attributes],{:owner_id=>current_user.id})

    # The nested attribute audience has habtm associations that don't play nicely with optimistic locking
    if(params[:forum][:audience_attributes])
      non_ids = params[:forum][:audience_attributes].reject{|key,value| key =~ /_ids$/}
      ids = params[:forum][:audience_attributes].reject{|key,value| !(key =~ /_ids$/)}
      params[:forum][:audience_attributes] = non_ids
    end

    begin
      if @forum.update_attributes(params[:forum])
        if params[:forum][:audience_attributes]
          # Once we're sure that forums and the audience itself isn't stale, we update the audience
          @audience = Audience.find_by_id(non_ids[:id])
          @audience.update_attributes(ids)

          # Force a lock_version increment for stale object detection on the audience itself
          Audience.update_counters params[:forum][:audience_attributes][:id], :lock_version => 1
        end

        if params[:forum][:topic_attributes]
          flash[:notice] = "Topic was successfully created."
          redirect_to forum_topics_path(@forum)
        else
          flash[:notice] = "Forum was successfully updated."
          redirect_to forums_path
        end
      else
        redirect_to :back
      end
    rescue ActiveRecord::StaleObjectError
      flash[:error] = "This forum was recently changed by another user.  Please try again."
      redirect_to edit_forum_path(@forum)
    rescue StandardError
      flash[:error] = "There was a problem updating the forum."
      redirect_to forums_path
    end
  end
  
  def destroy
    @forum = Forum.find_for(params[:id],current_user)
    @forum.destroy
    flash[:notice] = "Forum was successfully removed."
    redirect_to forums_url
  end
  
protected

  def merge_if(ahash,options={})
    # only merge in the options if the attributes have other values indicating valid attributes
    return ahash unless ( ahash.kind_of?(Hash) && options.kind_of?(Hash) )
    if ahash
      ahash.merge!(options)
    end
  end

end
