require 'rubygems'
require 'httparty'

class PivotalTracker
  include HTTParty
  base_uri 'www.pivotaltracker.com/services/v2'
  format :xml
  
  def initialize(api_token)
    self.class.headers 'X-TrackerToken' => api_token
  end
  
  def create_project(name, options = {})
    data = self.class.post('/projects/', :body => {:project => options.merge(:name => name)})
    project = PivotalTracker::Project.new(data['project'])
  end
  
  def add_member_to_project(project_id, role, email, person_options = {})
    data = self.class.post("/projects/#{project_id}/memberships/", :body => {:membership => {:role => role, :person => person_options.merge(:email => email)}})
    membership = PivotalTracker::Membership.new(data['membership'])
  end
  
  def remove_member_from_project(project_id, membership_id)
    data = self.class.delete("/projects/#{project_id}/memberships/#{membership_id}/")
    membership = PivotalTracker::Membership.new(data['membership']) if data['membership']
  end
end

require File.dirname(__FILE__) + '/pivotal_tracker/data'