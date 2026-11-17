require 'rails_helper'

RSpec.describe OauthController, type: :controller do
  describe 'GET #redirect_to_provider' do
    it 'redirects to the omniauth request path' do
      request.env['REQUEST_URI'] = '/signin_facebook'
      get :redirect_to_provider
      expect(response).to redirect_to('/users/auth/facebook')
    end

    it 'forwards the client identifier into the omniauth request path' do
      request.env['REQUEST_URI'] = '/signin_facebook?client=civis_v2'
      get :redirect_to_provider, params: { client: 'civis_v2' }
      expect(response).to redirect_to('/users/auth/facebook?client=civis_v2')
    end
  end

  describe 'GET #callback' do
    let!(:user) { Fabricate(:user) }

    before(:all) do
      Location.find_or_create_by!(name: 'Test City', location_type: :city)
      PointScale.find_or_create_by!(action: :user_created, points: 10, upper_limit: 100)
    end

    before do
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'facebook',
        uid: '12345',
        info: { email: user.email }
      )
    end

    it 'redirects to the default client' do
      get :callback, params: { provider: 'facebook' }
      expect(response.location).to start_with('http://localhost:3000/auth/success?access_token=')
    end

    context 'with the civis_v2 client identifier' do
      before { request.env['omniauth.params'] = { 'client' => 'civis_v2' } }

      it 'redirects to the v2 client' do
        get :callback, params: { provider: 'facebook' }
        expect(response.location).to start_with('http://localhost:3001/auth/success?access_token=')
      end
    end

    context 'with an unrecognised client identifier' do
      before { request.env['omniauth.params'] = { 'client' => 'https://evil.example.com' } }

      it 'falls back to the default client' do
        get :callback, params: { provider: 'facebook' }
        expect(response.location).to start_with('http://localhost:3000/auth/success?access_token=')
      end
    end
  end

  describe 'GET #failure' do
    it 'redirects to /auth/failure on the default client' do
      get :failure
      expect(response.location).to eq('http://localhost:3000/auth/failure')
    end

    it 'redirects to /auth/failure on the v2 client when identified' do
      request.env['omniauth.params'] = { 'client' => 'civis_v2' }
      get :failure
      expect(response.location).to eq('http://localhost:3001/auth/failure')
    end
  end
end
