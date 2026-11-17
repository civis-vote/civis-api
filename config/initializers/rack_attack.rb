Rack::Attack.throttled_responder = lambda do |_req|
  [
    429,
    { 'Content-Type' => 'application/json' },
    [{ error: 'Rate limit exceeded. Please try again later.' }.to_json]
  ]
end
