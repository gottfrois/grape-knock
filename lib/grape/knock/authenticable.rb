require 'knock'
require 'knock/authenticable'
require 'grape/knock/forbidden_error'
require 'grape/knock/methods'

module Grape
  module Knock
    class Authenticable < Grape::Middleware::Base
      include ::Knock::Authenticable

      def context
        env['api.endpoint']
      end

      def before
        authenticate
        context.extend Grape::Knock::Methods
        context.current_user = @current_user
      end

      private

      def authenticate
        fail ::Grape::Knock::ForbiddenError unless token
        @current_user = ::Knock::AuthToken.new(token: token).current_user
        fail ::Grape::Knock::ForbiddenError unless @current_user
      rescue ::JWT::DecodeError
        fail ::Grape::Knock::ForbiddenError
      end

      def token
        env['HTTP_AUTHORIZATION'].to_s.split(' ').last
      end

    end
  end
end
