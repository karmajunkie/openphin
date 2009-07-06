class PhinPeopleController < ApplicationController
  # GET /phin_people
  # GET /phin_people.xml
  def index
    @phin_people = PhinPerson.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phin_people }
    end
  end

  # GET /phin_people/1
  # GET /phin_people/1.xml
  def show
    @phin_person = PhinPerson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phin_person }
    end
  end

  # GET /phin_people/new
  # GET /phin_people/new.xml
  def new
    @phin_person = PhinPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phin_person }
    end
  end

  # GET /phin_people/1/edit
  def edit
    @phin_person = PhinPerson.find(params[:id])
  end

  # POST /phin_people
  # POST /phin_people.xml
  def create
    @phin_person = PhinPerson.new(params[:phin_person])

    respond_to do |format|
      if @phin_person.save
        flash[:notice] = 'PhinPerson was successfully created.'
        format.html { redirect_to(@phin_person) }
        format.xml  { render :xml => @phin_person, :status => :created, :location => @phin_person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phin_people/1
  # PUT /phin_people/1.xml
  def update
    @phin_person = PhinPerson.find(params[:id])

    respond_to do |format|
      if @phin_person.update_attributes(params[:phin_person])
        flash[:notice] = 'PhinPerson was successfully updated.'
        format.html { redirect_to(@phin_person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phin_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phin_people/1
  # DELETE /phin_people/1.xml
  def destroy
    @phin_person = PhinPerson.find(params[:id])
    @phin_person.destroy

    respond_to do |format|
      format.html { redirect_to(phin_people_url) }
      format.xml  { head :ok }
    end
  end
end
