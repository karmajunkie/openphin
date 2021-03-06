require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CascadeAlert do
  before do
    @jurisdiction = Factory(:jurisdiction)
    Factory(:jurisdiction).move_to_child_of(@jurisdiction)
    @cascade_alert = CascadeAlert.new(Factory(:alert, :author => Factory(:user)))
  end
  
  describe 'to_edxl' do
    
    it "should not blow up" do
      lambda {@cascade_alert.to_edxl}.should_not raise_error
    end
    
  end
end
