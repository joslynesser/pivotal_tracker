class PivotalTracker::Error < StandardError
  attr_reader :data
  
  def initialize(data)
    @data = data
    super
  end
end

class PivotalTracker::BadRequest        < PivotalTracker::Error; end
class PivotalTracker::Unauthorized      < PivotalTracker::Error; end

class PivotalTracker::General           < StandardError; end
class PivotalTracker::Unavailable       < StandardError; end
class PivotalTracker::InformPivotal     < StandardError; end
class PivotalTracker::ResourceNotFound  < StandardError; end
class PivotalTracker::ResourceInvalid  < StandardError; end
