Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do 
    origins Rails.application.config.allowed_cors_origins
    resource '*',
    methods: [:get, :post, :delete, :put, :patch, :options, :head],
    headers: :any,
    max_age: 600
  end
end