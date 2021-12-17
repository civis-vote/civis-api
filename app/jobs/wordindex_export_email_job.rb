class WordindexExportEmailJob < ApplicationJob
  queue_as :default

  def perform(wordindices, email)
    UserMailer.wordindex_export_email_job(wordindices, email).deliver_now
  end
end
