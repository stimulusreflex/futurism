module Futurism
  module Resolver
    class Resources
      include Futurism::MessageVerifier
      include Futurism::OptionsTransformer

      # resource definitions are an array of [signed_params, sgid, signed_controller, url, broadcast_each]
      def initialize(resource_definitions:, connection:, params:)
        @connection = connection
        @params = params
        @resources_with_sgids, @resources_without_sgids = resource_definitions
          .partition { |signed_params, sgid, *| sgid.present? }
          .map { |partition| partition.map { |definition| ResourceDefinition.new(definition) } }
      end

      def resolve
        resolved_models.zip(@resources_with_sgids).each do |model, resource_definition|
          html = renderer_for(resource_definition: resource_definition).render(model)

          yield(resource_definition.selector, html, resource_definition.broadcast_each)
        end

        @resources_without_sgids.each do |resource_definition|
          options = options_from_resource(resource_definition)
          renderer = renderer_for(resource_definition: resource_definition)
          html =
            begin
              renderer.render(options)
            rescue => exception
              error_renderer.render(exception)
            end

          yield(resource_definition.selector, html, resource_definition.broadcast_each)
        end
      end

      private

      def error_renderer
        ErrorRenderer.new
      end

      class ResourceDefinition
        attr_reader :signed_params, :sgid, :signed_controller, :url

        def initialize(resource_definition)
          @signed_params, @sgid, @signed_controller, @url, @broadcast_each = resource_definition
        end

        def selector
          selector = "[data-signed-params='#{@signed_params}']"
          selector << "[data-sgid='#{@sgid}']" if @sgid.present?
          selector
        end

        def controller
          Resolver::Controller.from(signed_string: @signed_controller)
        end

        def broadcast_each
          @broadcast_each == "true"
        end
      end

      class ErrorRenderer
        include ActionView::Helpers::TagHelper

        def render(exception)
          return "" unless render?

          Futurism.logger.error(exception.to_s)
          Futurism.logger.error(exception.backtrace)

          tag.div { tag.span(exception.to_s) + tag.div(exception.backtrace.join("\n"), style: "display: none;") }
        end

        def render?
          Rails.env.development? || Rails.env.test?
        end

        attr_accessor :output_buffer
      end

      def renderer_for(resource_definition:)
        Resolver::Controller::Renderer.for(controller: resource_definition.controller,
                                           connection: @connection,
                                           url: resource_definition.url,
                                           params: @params)
      end

      def resolved_models
        GlobalID::Locator.locate_many_signed @resources_with_sgids.map(&:sgid)
      end

      def options_from_resource(resource_definition)
        load_options(message_verifier
          .verify(resource_definition.signed_params))
      end
    end
  end
end
