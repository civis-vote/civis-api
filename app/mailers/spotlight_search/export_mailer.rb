module SpotlightSearch
  class ExportMailer < ActionMailer::Base
    default from: 'support@civis.vote'
    layout 'mailer'

    class << self; attr_accessor :postmark_key, :postmark_client end

    @postmark_key = Rails.application.credentials.postmark[:api_key]
    @postmark_client = Postmark::ApiClient.new(@postmark_key)

    def send_excel_file(email, file_path, subject)
      file = File.open(file_path)
      name = file_path.split('/').last
      user = User.find_by(email: email)
      # mail(to: email, subject: subject)
      ExportMailer.postmark_client.deliver_with_template(from: 'support@civis.vote',
                                                          to: email,
                                                          template_alias: 'export-spotlight-search',
                                                          template_model: {
                                                            first_name: user.first_name,
                                                          },
                                                          attachments: [{
                                                            name: name,
                                                            content: [file.read].pack('m'),
                                                            content_type: 'application/vnd.ms-excel',
                                                          }],
                                                        )
    end
  end
end
