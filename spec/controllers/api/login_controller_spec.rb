require 'rails_helper'

RSpec.describe "Authentication", type: :request do
let(:user) { User.create(name: "Test Admin", role: "admin", email: "test@example.com", password: "password") }
  
#   let(:user) { create(:user, password: 'password') }
#   let(:login_params) { "user": { email: user.email, password: user.password } }
  let(:headers) { { 'Content-Type' => 'application/json', 'Accept' => 'application/json' } }

  describe 'POST /users/sign_in' do
    context 'when valid credentials' do
      before do
        post '/users/sign_in', params: JSON.dump({
            "user": {
              "email": user.email,
              "password": user.password
            }
          }), headers: headers
      end
      
      it 'returns a success message' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({'message' => 'Login successful'})
      end

      it 'returns an auth token in the response header' do
        p response.headers['Authorization']
        expect(response.headers['Authorization']).to be_present
      end
    end

    context 'when invalid credentials' do
      before do
        post '/users/sign_in', params: JSON.dump({
            "user": {
              "email": user.email,
              "password": 'wrong_password'
            }
          }), headers: headers
      end

      it 'returns an error message' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not return an auth token in the response header' do
        expect(response.headers['Authorization']).to be_blank
      end
    end
  end
end
