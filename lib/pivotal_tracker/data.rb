require 'ostruct'

class PivotalTracker
  class Data < OpenStruct
    def initialize(data)
      @table = {}
      if data
        for key, value in data
          @table[key.to_sym] = value.instance_of?(Hash) ? Data.new(value) : value
          new_ostruct_member(key)
        end
      end
    end
  end
  
  class Project < Data; end
  class Membership < Data; end
end