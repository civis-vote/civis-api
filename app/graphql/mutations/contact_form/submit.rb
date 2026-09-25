module Mutations
  module ContactForm
    class Submit < Mutations::BaseMutation
      type Types::Objects::ContactForm::SubmitResponse, null: false

      argument :contact_form, Types::Inputs::ContactForm::Submit, required: true

      def resolve(contact_form:)
        details = contact_form.to_h

        CmAdmin.send_email(
          to: 'info@civis.vote',
          subject: "New contact form submission from #{details[:name]}",
          partial_file_path: 'cm_admin/mailers/contact_form/contact_form_email',
          partial_locals: details
        )

        { success: true, message: 'Thank you for contacting us. We will get back to you shortly.' }
      end
    end
  end
end
