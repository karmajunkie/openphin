require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesController do
  before(:each) do
    user = Factory(:user)
    Factory(:role_membership, :user => user, :role => Factory(:role, :approval_required => true), :jurisdiction => Factory(:jurisdiction))
    login_as(user)
  end
  
  describe 'show' do
    before do
      @user1 = Factory(:user, :last_name => 'Smith')
      @user2 = Factory(:user, :last_name => 'Smithers')
    end
    
    def do_action
      get :show, :q => 'smith', :format => 'json'
    end
      
    it 'should search the users' do
      User.should_receive(:search).and_return([])
      do_action
    end
    
    it 'should return users as a json object' do
      User.stub!(:search).and_return([@user1, @user2])
      do_action
      response.body.should have_text(Regexp.new(%|"caption": "#{@user1.name}"|))
      response.body.should have_text(Regexp.new(%|"value": #{@user1.id}|))
    end
  end
end