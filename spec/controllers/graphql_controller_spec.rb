require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  describe 'POST #execute' do
    describe 'contact form rate limit' do
      before do
        allow(Rails.cache).to receive(:increment) do |key, *_args|
          key.include?('skip-') ? 1 : 6
        end
      end

      it 'returns 429 once the per-IP limit for contact form submissions is exceeded' do
        post :execute, params: {
          query: 'mutation { contactFormSubmit(contactForm: { name: "John", email: "john@example.com", message: "Hello" }) { success } }'
        }

        expect(response).to have_http_status(:too_many_requests)
        expect(JSON.parse(response.body)['error']).to eq('Rate limit exceeded. Please try again later.')
      end

      it 'does not rate limit other GraphQL requests' do
        post :execute, params: { query: '{ __typename }' }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
