require 'rails_helper'

RSpec.describe Mutations::ContactForm::Submit, type: :graphql do
  let(:query) do
    <<~GQL
      mutation SubmitContactForm($contactForm: ContactFormSubmitInput!) {
        contactFormSubmit(contactForm: $contactForm) {
          success
          message
        }
      }
    GQL
  end

  let(:variables) do
    {
      contactForm: {
        name: 'John Doe',
        phoneNumber: '1234567890',
        organisationName: 'ACME Corp',
        message: 'Hello, I would like to know more about Civis.'
      }
    }
  end

  let(:context) { {} }

  let(:result) do
    CivisApiSchema.execute(query, variables: variables, context: context)
  end

  describe 'contactFormSubmit mutation' do
    it 'sends an email to info@civis.vote with the contact form details' do
      expect(CmAdmin).to receive(:send_email).with(
        hash_including(
          to: 'info@civis.vote',
          subject: 'New contact form submission from John Doe',
          partial_file_path: 'cm_admin/mailers/contact_form/contact_form_email',
          partial_locals: hash_including(
            name: 'John Doe',
            phone_number: '1234567890',
            organisation_name: 'ACME Corp',
            message: 'Hello, I would like to know more about Civis.'
          )
        )
      )

      submit_response = result.dig('data', 'contactFormSubmit')

      expect(submit_response['success']).to be true
      expect(submit_response['message']).to eq('Thank you for contacting us. We will get back to you shortly.')
      expect(result['errors']).to be_nil
    end

    it 'does not require optional fields' do
      variables[:contactForm] = { name: 'Jane Doe', message: 'Interested in joining.' }

      expect(CmAdmin).to receive(:send_email).with(
        hash_including(
          to: 'info@civis.vote',
          partial_locals: hash_including(name: 'Jane Doe', message: 'Interested in joining.')
        )
      )

      submit_response = result.dig('data', 'contactFormSubmit')

      expect(submit_response['success']).to be true
    end

    it 'returns an error when required fields are missing' do
      result = CivisApiSchema.execute(
        query,
        variables: { contactForm: { name: 'John Doe' } },
        context: {}
      )

      expect(result.dig('data', 'contactFormSubmit')).to be_nil
      expect(result['errors']).not_to be_empty
    end
  end
end
