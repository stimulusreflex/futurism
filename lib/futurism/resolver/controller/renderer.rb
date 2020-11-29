module Futurism
  module Resolver
    class Controller
      class Renderer
        def self.for(controller:, connection:, url:, params:)
          new(controller: controller, connection: connection, url: url, params: params).renderer
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
          if url.present?
            uri = URI.parse(url)
            path = ActionDispatch::Journey::Router::Utils.normalize_path(uri.path)
            query_hash = Rack::Utils.parse_nested_query(uri.query)

            path_params = Rails.application.routes.recognize_path(path)

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
      end
    end
  end
end
