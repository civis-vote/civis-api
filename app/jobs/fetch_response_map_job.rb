class FetchResponseMapJob < ApplicationJob
  queue_as :default
  require "uri"
	require "net/http"

  def perform(consultation_response)
  	cr = consultation_response
  	url = "http://35.223.43.106/venter/modelKM"
    uri = URI(url)
	  http = Net::HTTP.new(uri.host, uri.port)

	  request = Net::HTTP::Post.new(uri.path, {"Content-Type" => "application/json"})

    # SOME JSON DATA e.g {msg: 'Why'}.to_json
	  request.body = {"#{cr.consultation.title}": { "responses": ["#{cr.response_text}"], "summary": "#{cr.consultation.summary}" }}.to_json 

	  response = http.request(request)

	  body = JSON.parse(response.body)
	  Rails.cache.delete("response_hash_map")
	  Rails.cache.write("response_hash_map") do
      body
    end
  end
end