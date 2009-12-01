class DocumentsController < ApplicationController
  before_filter :non_public_role_required

 layout nil
  def panel_index
    @folders = current_user.folders.roots
    @shares = current_user.channels
    current_folder = current_user.folders.find(params[:id]) unless params[:id].blank?
    current_channel = current_user.channels.find(params[:channel]) unless params[:channel].blank?
    if current_folder
      @name = current_folder.name
      @documents = current_folder.documents
    elsif current_channel
      @name = current_channel.name
      @documents = current_channel.documents
    else
      @name = "Inbox"
      @documents = current_user.documents.inbox
    end
  end

  def index
    if params[:channel_id]
      if @channel = current_user.channels.find(params[:channel_id])
        @name = @channel.name
        @documents = @channel.documents
      else
        flash[:error] = "Channel does not exist"
        redirect_to documents_panel_path
      end
    elsif params[:folder_id]
      if folder = current_user.folders.find(params[:folder_id])
        @name = folder.name
        @documents = folder.documents
      else
        flash[:error] = "Folder does not exist"
        redirect_to documents_panel_path
      end
    else
      flash[:error] = "No Channel or Folder provided"
      redirect_to documents_panel_path
    end
  end
  
  def create
    folder = current_user.folders.find(params[:document][:folder_id].to_i)
    unless folder.documents.detect{|x| x.file_file_name == params[:document][:file].original_filename}
      @document = current_user.documents.build(params[:document])
      @document.save!
    else
      flash[:error] = 'File name is already in use. Try renaming the file.'
      @document = current_user.documents.build(params[:document])
    end
    redirect_to folder_or_inbox_path(@document)
  end
  
  def show
    @document = Document.viewable_by(current_user).find(params[:id])
    send_file @document.file.path, :type => @document.file_content_type, :disposition => 'attachment'
  end
  
  def edit
    @document = Document.editable_by(current_user).find(params[:id])
  end
  
  def update
    @document = Document.editable_by(current_user).find(params[:id])
    if @document.update_attributes(params[:document])
      redirect_to documents_panel_path
    else 
      render :edit
    end
  end

  def inbox
    @name = "Inbox"
    @documents = current_user.documents.inbox
    render "index"
  end
  
  def copy
    @document = Document.viewable_by(current_user).find(params[:id])
  end
  
  def remove_from_channel
    @document = Document.editable_by(current_user).find(params[:id])
    @channel = current_user.channels.find(params[:channel_id])
    @channel.documents.delete(@document)
    redirect_to folder_inbox_path
  end
  
  def remove_from_folder
    @document = Document.editable_by(current_user).find(params[:id])
    @folder = current_user.folders.find(params[:folder_id])
    @folder.documents.delete(@document)
    @document.destroy
    flash[:notice] = "Successfully removed the document from the folder."
    redirect_to @folder
  end
  
end
