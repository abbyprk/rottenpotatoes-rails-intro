class Movie < ActiveRecord::Base
    
    def self.get_ratings
        #TODO: only return the values that we actually have in the db?
       return ['G','PG','PG-13','R'] 
    end
end
