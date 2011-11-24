SimpleWorker.configure do |config|
    config.access_key = ENV['SIMPLE_WORKER_ACCESS_KEY']
    config.secret_key = ENV['SIMPLE_WORKER_SECRET_KEY']
    # Use the line below if you're using an ActiveRecord database
    #config.database = Rails.configuration.database_configuration[Rails.env]
end