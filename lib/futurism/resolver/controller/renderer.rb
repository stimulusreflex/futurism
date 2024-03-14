# frozen_string_literal: true

module Futurism
  module Resolver
    class Controller
      class Renderer
        HTTP_METHODS = [:get, :post, :put, :patch, :delete]

        def self.for(controller:, connection:, url:, params:)
          controller_renderer = new(
            controller: controller, connection: connection, url: url, params: params
          ).renderer

          Futurism.instrumentation? ? Instrumentation.new(controller_renderer) : controller_renderer
        end

        def initialize(controller:, connection:, url:, params:)
          @controller = controller
          @connection = connection
          @url = url || ""
          @params = params || {}

          setup_env!
        end

        def renderer
          @renderer ||= controller.renderer
        end

        private

        attr_reader :controller, :connection, :url, :params
        attr_writer :renderer

        def setup_env!
          unless url.nil?
            uri = URI.parse(url)
            path = ActionDispatch::Journey::Router::Utils.normalize_path(uri.path)
            query_hash = Rack::Utils.parse_nested_query(uri.query)

            path_params = recognize_url(url) # use full url to be more likely to match a url with subdomain constraints

            self.renderer =
              renderer.new(
                "rack.request.query_hash" => query_hash,
                "rack.request.query_string" => uri.query,
                "ORIGINAL_SCRIPT_NAME" => "",
                "ORIGINAL_FULLPATH" => path,
                Rack::SCRIPT_NAME => "",
                Rack::PATH_INFO => path,
                Rack::REQUEST_PATH => path,
                Rack::QUERY_STRING => uri.query,
                ActionDispatch::Http::Parameters::PARAMETERS_KEY => params.symbolize_keys.merge(path_params).merge(query_hash)
              )
          end

          # Copy connection env to renderer to fix some RACK related issues from gems like
          # Warden or Devise
          new_env = connection.env.merge(renderer.instance_variable_get(:@env))
          renderer.instance_variable_set(:@env, new_env)
        end

        def recognize_url(url)
          HTTP_METHODS.each do |http_method|
            path = Rails.application.routes.recognize_path(url, method: http_method)
            return path if path
          rescue ActionController::RoutingError
            # Route not matched, try next
          end

          warn "We were unable to find a matching rails route for '#{url}'. " \
               "This may be because there are proc-based routing constraints for this particular url, or " \
               "it truly is an unrecognizable url."

          {}
        end
      end
    end
  end
end
