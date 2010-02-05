$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pivotal_tracker'
require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'fakeweb'
require 'ruby-debug'

Spec::Runner.configure do |config|
  
end

FakeWeb.allow_net_connect = false

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def pivotal_tracker_url(url)
  url =~ /^http/ ? url : "http://www.pivotaltracker.com/services/v3#{url}"
end
 
def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?
  
  FakeWeb.register_uri(:get, pivotal_tracker_url(url), options)
end
 
def stub_post(url, filename)
  FakeWeb.register_uri(:post, pivotal_tracker_url(url), :body => fixture_file(filename))
end
 
def stub_put(url, filename)
  FakeWeb.register_uri(:put, pivotal_tracker_url(url), :body => fixture_file(filename))
end
 
def stub_delete(url, filename)
  FakeWeb.register_uri(:delete, pivotal_tracker_url(url), :body => fixture_file(filename))
end