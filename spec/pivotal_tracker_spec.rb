require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PivotalTracker" do
  
  describe "Initialization" do
    it "should require an API token" do
      lambda { PivotalTracker.new }.should raise_error(ArgumentError)
    end
    
    it "should assign the token to the HTTParty request headers" do
      @tracker = PivotalTracker.new('12345')
      PivotalTracker.default_options[:headers].should include('X-TrackerToken' => '12345')
    end
  end
  
  describe "Data" do
    before(:each) do
      @data = PivotalTracker::Data.new({'foo' => 'bar'})
    end
    
    it "should resemble a nested OpenStruct" do
      @data.foo.should == 'bar'
    end
    
    it "should return nil for missing keys" do
      @data.foobar.should be_nil
    end
  end
  
  describe "Projects" do
    before(:each) do
      @tracker = PivotalTracker.new('12345')
    end
    
    it "should create projects" do
      stub_post('/projects/', 'project.xml')
      project = @tracker.create_project('Cardassian War Plans')
      project.name.should == 'Cardassian War Plans'
    end
  end
  
  describe "Memberships" do
    before(:each) do
      @tracker = PivotalTracker.new('12345')
    end
    
    it "should add members to a given project" do
      stub_post('/projects/12345/memberships/', 'membership.xml')
      membership = @tracker.add_member_to_project(12345, 'Member', 'jadzia@trill.ufp')
      membership.person.name.should == 'Jadzia Dax'
    end
    
    it "should remove members from a given project" do
      stub_delete('/projects/12345/memberships/15007/', 'membership.xml')
      membership = @tracker.remove_member_from_project(12345, 15007)
      membership.person.name.should == 'Jadzia Dax'
    end
  end
  
  describe "Error Handling" do
    it "should be handled" do
      pending
    end
  end
end