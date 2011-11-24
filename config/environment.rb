# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
PowerRedirects::Application.initialize!

# SimpleWorker
PowerRedirects::Application.config.load_paths += %W( #{RAILS_ROOT}/app/workers )