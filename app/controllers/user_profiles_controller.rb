class UserProfilesController < ApplicationController
  before_filter(:except => [:show]) do |controller|
    controller.admin_or_self_required(:user_id)
  end

  # GET /users
  # GET /users.xml
  def index
    set_toolbar
    @users = User.all

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    set_toolbar
    @user = User.find(params[:user_id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    set_toolbar
    User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    set_toolbar
    find_user_and_profile
  end

  # POST /users
  # POST /users.xml
  def create
    set_toolbar
    @user=User.find(params[:user_id])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    set_toolbar
    find_user_and_profile

    # Profile form will return blank devices due to hidden fields used to add devices via ajax
    Device::Types.map(&:name).map(&:demodulize).each do |device_type|
      if params[device_type].values.first.blank?
        params.delete(device_type)
      end
    end

    if Device::Types.map(&:name).map(&:demodulize).include?(params[:device_type])
      @device = device_class_for(params[:device_type]).new params[params[:device_type]]
      @device.user = @user
    end

    params[:user][:role_requests_attributes].each do |index, role_request|
      if role_request[:role_id].blank? && role_request[:jurisdiction_id].blank?
        params[:user][:role_requests_attributes].delete(index)
        next
      end
      jurisdiction = Jurisdiction.find(role_request[:jurisdiction_id])
      if jurisdiction && current_user.is_admin_for?(jurisdiction)
        existing_request = RoleRequest.find_by_user_id_and_role_id_and_jurisdiction_id(params[:user_id], role_request['role_id'], role_request['jurisdiction_id'])
        if existing_request
          existing_request.destroy
        end
      end
      unless params[:user_id] == current_user.id
        role_request[:requester_id] = current_user.id 
      end
    end

    omr = params[:user][:organization_membership_requests_attributes]
    omr.each do |index, request|
      params[:user][:organization_membership_requests_attributes].delete(index) if request[:organization_id].blank?
      request[:approver_id] = current_user.id if current_user.is_super_admin?
    end unless omr.nil?

    if !params[:user][:photo].blank?
      @user.photo=params[:user][:photo]
      params[:user].delete("photo")
    end

    if params[:user][:password] == "******"
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    respond_to do |format|
      begin
        if @user.update_attributes(params[:user]) && (@device.nil? || @device.save)
          params[:user][:role_requests_attributes].each do |index, role_requests|
            rr = @user.role_requests.find_by_role_id_and_jurisdiction_id(role_requests['role_id'], role_requests['jurisdiction_id'])
            if !rr.approved? && current_user.is_admin_for?(rr.jurisdiction)
              rr.approve!(current_user)
            end
          end

          params[:user][:organization_membership_requests_attributes].each do |index, request|
            omr = @user.organization_membership_requests.find_by_organization_id(request['organization_id'])
            if !omr.approved? && current_user.is_super_admin?
              omr.approve!(current_user)
            else
              flash[:notice] = "Your request to be a member of #{omr.organization.name} has been sent to an administrator for approval."
            end
          end unless params[:user][:organization_membership_requests_attributes].nil?

          flash[:notice] = "" if flash[:notice].blank?
          flash[:notice] += flash[:notice].blank? ? 'Profile information saved.' : "<br/><br/>Profile information saved."
          format.html { redirect_to user_profile_path(@user) }
          format.xml { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      rescue ActiveRecord::StaleObjectError
        flash[:error] = "Another user has recently updated this profile, please try again."
        find_user_and_profile
        format.html { render :action => "edit"}
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      rescue StandardError
        flash[:error] = "An error has occurred saving your profile, please try again."
        find_user_and_profile
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def device_class_for(device_type)
    ("#{Device.name}::" + params[:device_type]).constantize
  end

  def find_user_and_profile
    @user = User.find(params[:user_id], :include => [:role_memberships])
    unless @user.editable_by?(current_user)
      flash[:notice] = "You are not authorized to edit this profile."
      redirect_to :back
    end
  end

  def set_toolbar
    if params[:user_id] == current_user.id.to_s
      self.class.app_toolbar "accounts"
    else
      self.class.app_toolbar "application"
    end
  end
    
end
