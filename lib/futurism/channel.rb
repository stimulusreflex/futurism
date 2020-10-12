module Futurism
  class Channel < ActionCable::Channel::Base
    include CableReady::Broadcaster
    include Futurism::MessageVerifier

    def stream_name
      ids = connection.identifiers.map { |identifier| send(identifier).try(:id) || send(identifier) }
      [
        params[:channel],
        ids.select(&:present?).join(";")
      ].select(&:present?).join(":")
    end

    def subscribed
      stream_from stream_name
    end

    def receive(data)
      resources = data.fetch_values("signed_params", "sgids", "signed_controllers") { |_key| Array.new(data["signed_params"].length, nil) }.transpose

      resources.each do |signed_params, sgid, signed_controller|
        selector = "[data-signed-params='#{signed_params}']"
        selector << "[data-sgid='#{sgid}']" if sgid.present?

        controller_lookup = ControllerLookup.from(signed_string: signed_controller)
        controller_lookup.setup_env!(connection: connection)
        controller = controller_lookup.controller

        resource = lookup_resource(signed_params: signed_params, sgid: sgid)
        html = controller.render(resource)

        cable_ready[stream_name].outer_html(
          selector: selector,
          html: html
        )
      end

      cable_ready.broadcast
    end

    private

    def lookup_resource(signed_params:, sgid:)
      return GlobalID::Locator.locate_signed(sgid) if sgid.present?

      message_verifier
        .verify(signed_params)
        .deep_transform_values { |value| value.is_a?(String) && value.start_with?("gid://") ? GlobalID::Locator.locate(value) : value }
    end

    class ControllerLookup
      include Futurism::MessageVerifier

      def self.from(signed_string:)
        new(signed_string)
      end

      def initialize(signed_string)
        @signed_string = signed_string
      end

      def controller
        if signed_string.present?
          message_verifier
            .verify(signed_string)
            .to_s
            .safe_constantize
        else
          default_controller
        end
      end

      def setup_env!(connection:)
        new_env = connection.env.merge(controller.renderer.instance_variable_get(:@env))
        controller.renderer.instance_variable_set(:@env, new_env)
      end

      private

      attr_reader :signed_string

      def default_controller
        Futurism.default_controller || ::ApplicationController
      end
    end
  end
end
