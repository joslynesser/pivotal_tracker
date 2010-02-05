require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PivotalTracker do
  
  describe "Initialization" do
    it "should require an API token" do
      lambda { PivotalTracker.new }.should raise_error(ArgumentError)
    end
    
    it "should assign the token to the HTTParty request headers" do
      @tracker = PivotalTracker.new('12345')
      PivotalTracker.default_options[:headers].should include('X-TrackerToken' => '12345')
    end

    it "does not use SSL by default" do
      @tracker = PivotalTracker.new('12345')
      PivotalTracker.default_options[:base_uri].should match(/^http:/)
    end

    it "accepts an option for SSL" do
      @tracker = PivotalTracker.new('12345', :ssl => true)
      PivotalTracker.default_options[:base_uri].should match(/^https/)
    end
  end
  
  describe "API" do
    before(:each) do
      @tracker = PivotalTracker.new('12345')      
    end

    describe "Activities" do
      it "should get all recent activities" do
        stub_get('/activities', 'activities.xml')
        activities = @tracker.get_all_activities
        activities.first.description.should == "James Kirk accepted \"More power to shields\""
      end
      
      it "should filter recent activities" do
        stub_get('/activities?newer_than_version=170', 'activities.xml')
        activities = @tracker.get_all_activities(:newer_than_version => 170)
        activities.first.description.should == "James Kirk accepted \"More power to shields\""
      end
      
      it "should get all recent activities for a given project" do
        stub_get('/projects/1/activities', 'activities.xml')
        activities = @tracker.get_all_project_activities(1)
        activities.first.description.should == "James Kirk accepted \"More power to shields\""
      end
      
      it "should filter recent activities for a given project" do
        stub_get('/projects/1/activities?limit=50', 'activities.xml')
        activities = @tracker.get_all_project_activities(1, :limit => 50)
        activities.first.description.should == "James Kirk accepted \"More power to shields\""
      end
    end
    
    describe "Projects" do
      it "should get all projects" do
        stub_get('/projects', 'projects.xml')
        projects = @tracker.get_all_projects
        projects.first.name.should == 'Sample Project'
        projects.first.memberships.first.person.name.should == 'James T. Kirk'
      end
      
      it "should get a project" do
        stub_get("/projects/27", 'project.xml')
        project = @tracker.get_project(27)
        project.name.should == 'Sample Project'
      end
      
      it "should create a project" do
        stub_post('/projects', 'project.xml')
        project = @tracker.create_project('Cardassian War Plans')
        project.name.should == 'Sample Project'
      end
      
      it "should create a project with options" do
        stub_post('/projects', 'project.xml')
        project = @tracker.create_project('Cardassian War Plans', :no_owner => true)
        project.name.should == 'Sample Project'
      end
    end
  
    describe "Memberships" do
      it "should get all memberships for a given project" do
        stub_get('/projects/1/memberships', 'memberships.xml')
        memberships = @tracker.get_all_project_memberships(1)
        memberships.first.person.name.should == 'Jean-Luc Picard'
      end
      
      it "should get a single membership for a given project" do
        stub_get('/projects/1/memberships/15007', 'membership.xml')
        membership = @tracker.get_project_membership(1, 15007)
        membership.person.name.should == 'Jadzia Dax'
      end
      
      it "should add memberships to a given project" do
        stub_post('/projects/12345/memberships', 'membership.xml')
        membership = @tracker.add_project_membership(12345, 'Member', 'jadzia@trill.ufp')
        membership.person.name.should == 'Jadzia Dax'
      end
    
      it "should remove memberships from a given project" do
        stub_delete('/projects/12345/memberships/15007', 'membership.xml')
        membership = @tracker.remove_project_membership(12345, 15007)
        membership.person.name.should == 'Jadzia Dax'
      end
    end
    
    describe "Iterations" do
      it "should get all iterations for a given project" do
        stub_get('/projects/1/iterations', 'iterations.xml')
        iterations = @tracker.get_all_project_iterations(1)
        iterations.first.stories.first.story_type.should == 'feature'
      end
      
      it "should get iterations filtered by done, current, or backlog" do
        pending
      end
      
      it "should get iterations by limit and offset" do
        stub_get('/projects/1/iterations?offset=1&limit=2', 'iterations.xml')
        iterations = @tracker.get_all_project_iterations(1, :offset => 1, :limit => 2)
        iterations.first.stories.first.story_type.should == 'feature'
      end
    end
    
    describe "Stories" do
      it "should get all stories for a given project" do
        stub_get('/projects/1/stories', 'stories.xml')
        stories = @tracker.get_all_project_stories(1)
        stories.first.owned_by.should == 'Montgomery Scott'
      end
      
      it "should get all stories for a project based on a given filter" do
        pending
      end
      
      it "should get all stories for a project paginated by a limit and offset" do
        pending
      end
      
      it "should create a new story for a given project" do
        pending
      end
    end
  end
  
  describe "Error Handling" do
    it "should be spec'd" do
      pending
    end
  end
end
