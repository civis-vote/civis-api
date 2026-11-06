class GupshupWhatsappDelivery
  GUPSHUP_API_URL = 'https://api.gupshup.io/wa/api/v1/template/msg'.freeze
  OTP_PURPOSE = 'Login'.freeze

  def initialize
    credentials = Rails.application.credentials[:gupshup] || {}
    @api_key = credentials[:api_key]
    @source = credentials[:source_number]
    @source_name = credentials[:source_name]
    @templates = credentials[:templates] || {}
  end

  def deliver(user:, otp:, template:)
    phone_number = user.phone_number
    raise 'User does not have a phone_number' if phone_number.blank?

    template_id = @templates[template.to_sym]
    raise 'No Gupshup template configured.' if template_id.blank?

    send_message(phone_number:, template_id:, template_params: [otp.to_s, OTP_PURPOSE, otp.to_s, OTP_PURPOSE])
  end

  private

  def send_message(phone_number:, template_id:, template_params:)
    uri = URI(GUPSHUP_API_URL)
    request = Net::HTTP::Post.new(uri)
    request['apikey'] = @api_key
    request.set_form_data(
      'channel' => 'whatsapp',
      'source' => @source.to_s.gsub(/\D/, ''),
      'src.name' => @source_name.to_s,
      'destination' => phone_number.to_s.gsub(/\D/, ''),
      'template' => { id: template_id, params: template_params }.to_json
    )

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.write_timeout = 10
      http.read_timeout = 10
      http.request(request)
    end
    raise "Gupshup WhatsApp delivery failed: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    response
  end
end
