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
          messages: [
            {sender: 'Kirill', body: 'Hello world!', reciever: 'w123', service: 'whatsapp'},
            {sender: 'Sergey', body: 'Salut world!', reciever: 'v123', service: 'viber'},
            {sender: 'Petr', body: 'Holla world!', reciever: 't123', service: 'telegram'},
            {sender: 'Kirill', body: 'Hello world!', reciever: 'w123', service: 'whatsapp'},
            ],
          access_token: access_token.token,
          format: :json
        }
      end

      it 'returns 207 status' do
        post '/api/v1/messages/', params: params
        expect(response.status).to eq 207
      end

      it 'creates new message in db' do
        expect { post '/api/v1/messages/', params: params }.to change(Message, :count).by(3)
      end
    end

    context 'authorized and post invalid data' do
      let(:user) { create(:user) }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }
      let(:params) do
        {
          messages: [
            {sender: 'Pavel', body: 'Hello world!', reciever: 't123', service: 'Slack'},
            {sender: 'Pavel', body: 'Hello world!', reciever: 'w123', service: nil},
            {sender: 'Pavel', body: 'Hello world!', reciever: nil, service: 'whatsapp'},
            {sender: 'Pavel', body: nil, reciever: 'w123', service: 'whatsapp'},
            {sender: nil, body: 'Hello world!', reciever: 'w123', service: 'whatsapp'},
            ],
          access_token: access_token.token,
          format: :json
        }
      end

      before do
        post '/api/v1/messages/', params: params
      end

      it 'returns 207 status' do
        expect(response.status).to eq 207
      end

      it 'returns errors' do
        expect(response.body).to have_json_size(5)
      end

      it 'does not creates new message in db' do
        expect { post '/api/v1/messages/', params: params }.not_to change(Message, :count)
      end
    end

    context 'authorized and post duplicate data' do
      let(:user) { create(:user) }
      let(:message) { create(:message, sender: 'Kirill', body: 'Hello world!', reciever: 'w123', service: 'whatsapp', wn: Date.today.strftime("%U").to_i, created_at: '2017-01-01') }
      let(:access_token) { create(:access_token, resource_owner_id: user.id) }
      let(:params) do
        {
          messages: [
            {sender: 'Kirill', body: 'Hello world!', reciever: 'w123', service: 'whatsapp'},
            ],
          access_token: access_token.token,
          format: :json
        }
      end

      before do
        post '/api/v1/messages/', params: params
      end

      it 'returns 207 status' do
        expect(response.status).to eq 207
      end

      it 'returns errors' do
        expect(response.body).to have_json_size(1)
      end

      it 'does not creates new message in db' do
        expect { post '/api/v1/messages/', params: params }.not_to change(Message, :count)
      end
    end
  end
end
