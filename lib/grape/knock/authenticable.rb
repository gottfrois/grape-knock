require 'knock'
require 'knock/authenticable'
require 'grape/knock/forbidden_error'

module Grape
  module Knock
    class Authenticable < Grape::Middleware::Base
      include ::Knock::Authenticable

      def initialize(_, options = {})
       super
       define_current_entity_getter entity_class, getter_name
     end

      def context
        env['api.endpoint']
      end

      def before
        authenticate

        memoization_var_name = "@_#{getter_name}"
        context.send(:instance_variable_set, memoization_var_name, send(getter_name))
        context.class.send(:define_method, getter_name) { instance_variable_get memoization_var_name }
      end

      private

      def authenticate
        fail ::Grape::Knock::ForbiddenError unless token
        fail ::Grape::Knock::ForbiddenError unless send(getter_name)
      rescue ::JWT::DecodeError
        fail ::Grape::Knock::ForbiddenError
      end

      def define_current_entity_getter(entity_class, getter_name)
        unless self.respond_to?(getter_name)
          memoization_var_name = "@_#{getter_name}"
          self.class.send(:define_method, getter_name) do
            unless instance_variable_defined?(memoization_var_name)
              current =
                begin
                  ::Knock::AuthToken.new(token: token).entity_for(entity_class)
                rescue ::Knock.not_found_exception_class, JWT::DecodeError
                  nil
                end
              instance_variable_set(memoization_var_name, current)
            end
            instance_variable_get(memoization_var_name)
          end
        end
      end

      def entity_class
        @options[:entity_class] || Object.const_get('User')
      end

      def getter_name
        "current_#{entity_class.to_s.parameterize.underscore}".freeze
      end

      def header_name
        (@options[:header_name] || 'HTTP_AUTHORIZATION').freeze
      end

      def token
        env[header_name].to_s.split(' ').last
      end
    end
  end
end
