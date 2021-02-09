module Futurism
  module Resolver
    class Resources
      include Futurism::MessageVerifier

      # resource definitions are an array of [signed_params, sgid, signed_controller, url]
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

          yield(resource_definition.selector, html)
        end

        @resources_without_sgids.each do |resource_definition|
          resource = lookup_resource(resource_definition)
          html = renderer_for(resource_definition: resource_definition).render(resource)

          yield(resource_definition.selector, html)
        end
      end

      private

      class ResourceDefinition
        attr_reader :signed_params, :sgid, :signed_controller, :url

        def initialize(resource_definition)
          @signed_params, @sgid, @signed_controller, @url = resource_definition
        end

        def selector
          selector = "[data-signed-params='#{@signed_params}']"
          selector << "[data-sgid='#{@sgid}']" if @sgid.present?
          selector
        end

        def controller
          Resolver::Controller.from(signed_string: @signed_controller)
        end
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

      def lookup_resource(resource_definition)
        message_verifier
          .verify(resource_definition.signed_params)
          .deep_transform_values { |value| value.is_a?(String) && value.start_with?("gid://") ? GlobalID::Locator.locate(value) : value }
      end
    end
  end
end
