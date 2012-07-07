require 'rubygems'
require 'httparty'
require 'mash'

class PivotalTracker
  
  include HTTParty
  format :xml
  
  def initialize(api_token, options = {})
    self.class.headers 'X-TrackerToken' => api_token
    use_ssl = options.delete(:ssl)
    self.class.base_uri "http#{'s' if use_ssl}://www.pivotaltracker.com/services/v3"
  end
  
  def get_all_activities(options = {})
    response = self.class.get("/activities", :query => options)
    raise_errors(response)
    parse_response(response, 'activities')
  end
  
  def get_all_project_activities(project_id, options = {})
    response = self.class.get("/projects/#{project_id}/activities", :query => options)
    raise_errors(response)
    parse_response(response, 'activities')
  end
  
  def get_all_projects
    response = self.class.get("/projects")
    raise_errors(response)
    parse_response(response, 'projects')
  end
  
  def get_project(project_id)
    response = self.class.get("/projects/#{project_id}")
    raise_errors(response)
    parse_response(response, 'project')
  end
  
  def create_project(name, options = {})
    response = self.class.post('/projects', :body => {:project => options.merge(:name => name)})
    raise_errors(response)
    parse_response(response, 'project')
  end
  
  def get_all_project_memberships(project_id)
    response = self.class.get("/projects/#{project_id}/memberships")
    raise_errors(response)
    parse_response(response, 'memberships')
  end
  
  def get_project_membership(project_id, membership_id)
    response = self.class.get("/projects/#{project_id}/memberships/#{membership_id}")
    raise_errors(response)
    parse_response(response, 'membership')
  end
  
  def add_project_membership(project_id, role, email, options = {})
    response = self.class.post("/projects/#{project_id}/memberships", :body => {:membership => {:role => role, :person => options.merge(:email => email)}})
    raise_errors(response)
    parse_response(response, 'membership')
  end
  
  def remove_project_membership(project_id, membership_id)
    response = self.class.delete("/projects/#{project_id}/memberships/#{membership_id}")
    raise_errors(response)
    parse_response(response, 'membership')
  end
  
  def get_all_project_iterations(project_id, options = {})
    response = self.class.get("/projects/#{project_id}/iterations", :query => options)
    raise_errors(response)
    parse_response(response, 'iterations')
  end
  
  def get_all_project_stories(project_id, options = {})
    if options[:filter]
      options[:filter] = options[:filter].map {|k,v| v ? "#{k}:#{v}" : k }.join(' ')
    end

    response = self.class.get("/projects/#{project_id}/stories", :query => options)
    raise_errors(response)
    parse_response(response, 'stories')
  end

  def add_project_story(project_id, story)
    response = self.class.post("/projects/#{project_id}/stories", :body => {:story => story})
    raise_errors(response)
    parse_response(response, 'story')
  end

  def update_project_story(project_id, story_id, story)
    response = self.class.put("/projects/#{project_id}/stories/#{story_id}", :body => {:story => story})
    raise_errors(response)
    parse_response(response, 'story')
  end

  def delete_project_story(project_id, story_id)
    response = self.class.delete("/projects/#{project_id}/stories/#{story_id}")
    raise_errors(response)
    parse_response(response, 'story')
  end

  def add_project_story_note(project_id, story_id, text)
    response = self.class.post("/projects/#{project_id}/stories/#{story_id}/notes", :body => {:note => {:text => text}})
    raise_errors(response)
    parse_response(response, 'note')
  end
  
  def move_project_story(project_id, story_id, direction, target_story_id)
    response = self.class.post("/projects/#{project_id}/stories/#{story_id}/moves", :body => {:move => {:move => direction, :target => target_story_id}})
    raise_errors(response)
    parse_response(response, 'story')
  end
    
  private
  
    def raise_errors(response)
      case response.code.to_i
        when 400
          raise PivotalTracker::BadRequest.new(response), "(#{response.code}): #{response.message} - #{response['message'] if response}"
        when 401
          raise PivotalTracker::Unauthorized.new(response), "(#{response.code}): #{response.message} - #{response.body if response}"
        when 403
          raise PivotalTracker::General, "(#{response.code}): #{response.message}"
        when 404
          raise PivotalTracker::ResourceNotFound, "(#{response.code}): #{response.message}"
        when 422
          raise PivotalTracker::ResourceInvalid, "(#{response.code}): #{response['errors'].inspect if response['errors']}"
        when 500
          raise PivotalTracker::InformPivotal, "Pivotal Tracker had an internal error. Please let them know. (#{response.code}): #{response.message} - #{response['message'] if response}"
        when 502..503
          raise PivotalTracker::Unavailable, "(#{response.code}): #{response.message}"
      end
    end
    
    # Create Mash objects from response data for the given resource(s)
    def parse_response(response, resource)
      response = cleanup_pivotal_data(response.body)
      data = response[resource]
      if data.is_a?(Array)
        data.collect {|object| Mash.new(object)}
      else
        Mash.new(data)
      end
    end
    
    # Make Crack's XML parsing happy by correctly defining Pivotal's nested collections as arrays
    # This can be removed when all collections returned by Pivotal Tracker's API have the type=array attribute set
    def cleanup_pivotal_data(body)
      %w{ projects memberships iterations stories }.each do |resource|
        body.gsub!("<#{resource}>", "<#{resource} type=\"array\">")
      end
      response = Crack::XML.parse(body)
    end
end

require File.dirname(__FILE__) + '/pivotal_tracker/error'
