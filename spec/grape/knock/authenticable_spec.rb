require 'spec_helper'

describe Grape::Knock::Authenticable do
  class User; end

  module Knock
    class AuthToken
      def initialize(options); end
      def entity_for(klass); klass end
    end
  end

  subject { app }

  describe 'using middleware' do
    context 'using with default options' do
      let(:app) do
        Class.new(Grape::API) do
          use Grape::Knock::Authenticable

          get '/curent_user' do
            current_user
          end
        end
      end

      it 'returns current_user' do
        get '/curent_user', {}, { 'HTTP_AUTHORIZATION' => 'test' }

        expect(last_response.body).to eq 'User'
      end
    end

    context 'using with custom header' do
      let(:app) do
        Class.new(Grape::API) do
          use Grape::Knock::Authenticable, header_name: 'CUSTOM'

          get '/curent_user' do
            current_user
          end
        end
      end

      context 'send request with custom header' do
        it 'returns 200 status' do
          get '/curent_user', {}, { 'CUSTOM' => 'test' }

          expect(last_response.status).to eq 200
        end
      end

      context 'send request with default header' do
        it 'raises error' do
          expect {
            get '/curent_user', {}, { 'HTTP_AUTHORIZATION' => 'test' }
          }.to raise_error(Grape::Knock::ForbiddenError)
        end
      end
    end

    context 'using with custom user class' do
      class Admin; end

      let(:app) do
        Class.new(Grape::API) do
          use Grape::Knock::Authenticable, entity_class: Admin

          get '/curent_user' do
            current_admin
          end
        end
      end

      it 'returns current_admin' do
        get '/curent_user', {}, { 'HTTP_AUTHORIZATION' => 'test' }

        expect(last_response.body).to eq 'Admin'
      end
    end
  end
end
