Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do 
    origins 'localhost:[0-9]+',
    '127.0.0.1:[0-9]+',
    'https://*.civis.vote'
    resource '*',
    methods: [:get, :post, :delete, :put, :patch, :options, :head],
    headers: :any,
    max_age: 600
  end
end