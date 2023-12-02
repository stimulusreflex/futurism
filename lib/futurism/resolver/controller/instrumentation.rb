require "active_support/notifications"

module Futurism
  module Resolver
    class Controller
      class Instrumentation < SimpleDelegator
        PARAMETERS_KEY = ActionDispatch::Http::Parameters::PARAMETERS_KEY

        def render(*args)
          ActiveSupport::Notifications.instrument(
            "render.futurism",
            channel: get_param(:channel),
            controller: get_param(:controller),
            action: get_param(:action),
            partial: extract_partial_name(*args)
          ) do
            super(*args)
          end
        end

        private

        def get_param(key)
          __getobj__.instance_variable_get(:@env).dig(PARAMETERS_KEY, key)
        end

        def extract_partial_name(opts_or_model, *args)
          opts_or_model.is_a?(Hash) ? opts_or_model[:partial] : opts_or_model.to_partial_path
        end
      end
    end
  end
end
