puts ''; User.find_by(email: 'joe.user@example.com').keys.each {|key| puts key.key; puts '' }
