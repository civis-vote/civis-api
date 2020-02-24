class AnalyseKeywordsForConsultationJob < ApplicationJob
  queue_as :default
  require "uri"
	require "net/http"

  def perform(consultation_response)
  	cr = consultation_response
  	url = Rails.application.credentials.dig(:venter_api_uri)
    uri = URI(url)
	  http = Net::HTTP.new(uri.host, uri.port)

	  request = Net::HTTP::Post.new(uri.path, {"Content-Type" => "application/json"})

	  # SOME JSON DATA e.g {msg: 'Why'}.to_json
	  request.body = {"#{cr.consultation.title}": { "responses": ["#{cr.response_text.to_plain_text}"], "summary": "#{cr.consultation.summary.to_plain_text}" }}.to_json 

	  response = http.request(request)

	  body = JSON.parse(response.body)
	  Rails.cache.delete("consultation_keyword_analysis_#{cr.consultation.id}")
	  Rails.cache.write("consultation_keyword_analysis_#{cr.consultation.id}", body)
  end
end