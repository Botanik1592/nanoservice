require 'rails_helper'

describe 'Recieve messages API' do
  describe 'POST #create' do

    context 'unauthorized' do
      it 'returns 401 status if there is no access_token' do
        post '/api/v1/messages/', params: { format: :json }
        expect(response.status).to eq 401
      end

      it 'returns 401 status if access_token is invalid' do
        post '/api/v1/messages/', params: { format: :json, access_token: '1234' }
        expect(response.status).to eq 401
      end
    end

    context 'authorized and post valida data' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }
      let(:params) do
        {
          body: 'Hello, John!',
          sender: 'Pavel',
          reciever: { whatsapp: 'wa1234', telegram: 't1234', viber: 'v1234' },
          access_token: access_token.token,
          format: :json
        }
      end

      before do
        post '/api/v1/messages/', params: params
      end

      it 'returns 201 status' do
        expect(response.status).to eq 201
      end

      it 'creates new message in db' do
        expect { post '/api/v1/messages/', params: params }.to change(Message, :count).by(3)
      end
    end

    context 'authorized and post invalida data' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }
      let(:params) do
        {
          sender: 'Pavel',
          reciever: { whatsapp: 'wa1234', telegram: 't1234', viber: 'v1234' },
          access_token: access_token.token,
          format: :json
        }
      end

      before do
        post '/api/v1/messages/', params: params
      end

      it 'returns 422 status' do
        expect(response.status).to eq 422
      end

      it 'returns errors' do
        expect(response.body).to have_json_size(2).at_path("errors")
      end

      it 'does not creates new message in db' do
        expect { post '/api/v1/messages/', params: params }.not_to change(Message, :count)
      end
    end
  end
end
