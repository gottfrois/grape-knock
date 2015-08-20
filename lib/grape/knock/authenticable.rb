require 'knock'
require 'knock/authenticable'
require 'grape/knock/forbidden_error'

module Grape
  module Knock
    class Authenticable < Grape::Middleware::Base
      include ::Knock::Authenticable

      def token
        env['HTTP_AUTHORIZATION'].to_s.split(' ').last
      end

      def authenticate
        fail ::Grape::Knock::ForbiddenError unless token
        ::Knock::AuthToken.new(token: token).current_user
      rescue ::JWT::DecodeError
        fail ::Grape::Knock::ForbiddenError
      end

      def before
        authenticate
      end

    end
  end
end
