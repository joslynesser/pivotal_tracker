$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'pivotal_tracker'
require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'fakeweb'

Spec::Runner.configure do |config|
  
end

FakeWeb.allow_net_connect = false