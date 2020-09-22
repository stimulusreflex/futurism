module Futurism
  class Channel < ActionCable::Channel::Base
    include CableReady::Broadcaster

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
      resources = data.fetch_values("signed_params", "sgids") { |key| [nil] }.transpose

      new_env = connection.env.merge(ApplicationController.renderer.instance_variable_get(:@env))
      ApplicationController.renderer.instance_variable_set(:@env, new_env)

      resources.each do |signed_params, sgid|
        selector = "[data-signed-params='#{signed_params}']"
        selector << "[data-sgid='#{sgid}']" if sgid.present?
        cable_ready[stream_name].outer_html(
          selector: selector,
          html: ApplicationController.render(resource(signed_params: signed_params, sgid: sgid))
        )
      end

      cable_ready.broadcast
    end

    private

    def resource(signed_params:, sgid:)
      return GlobalID::Locator.locate_signed(sgid) if sgid.present?

      Rails
        .application
        .message_verifier("futurism")
        .verify(signed_params)
        .deep_transform_values { |value| value.is_a?(String) && value.start_with?("gid://") ? GlobalID::Locator.locate(value) : value }
    end
  end
end
