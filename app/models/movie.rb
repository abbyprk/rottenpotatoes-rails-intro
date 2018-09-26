class Movie < ActiveRecord::Base
    
    def self.get_ratings
        ratings = []
        result = self.select(:rating).distinct
        result.each { |row|
            ratings.push(row['rating'])
        }
        return ratings
    end
end
