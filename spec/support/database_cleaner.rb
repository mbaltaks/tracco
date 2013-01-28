require 'database_cleaner'
 
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.orm = 'mongoid'
    DatabaseCleaner.strategy = :truncation
  end
 
  config.before(:each) do
    DatabaseCleaner.clean
  end
end
