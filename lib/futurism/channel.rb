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
      resources = data.fetch_values("signed_params", "sgids", "signed_controllers") { |key|; Array.new(data["signed_params"].length, nil) }.transpose
      new_env = connection.env.merge(ApplicationController.renderer.instance_variable_get(:@env))
      ApplicationController.renderer.instance_variable_set(:@env, new_env)

      resources.each do |signed_params, sgid, signed_controller|
        selector = "[data-signed-params='#{signed_params}']"
        selector << "[data-sgid='#{sgid}']" if sgid.present?
        html = controller(signed_controller: signed_controller).render(resource(signed_params: signed_params, sgid: sgid))
        cable_ready[stream_name].outer_html(
          selector: selector,
          html: html
        )
      end

      cable_ready.broadcast
    end

    private

    def resource(signed_params:, sgid:)
      return GlobalID::Locator.locate_signed(sgid) if sgid.present?

      message_verifier
        .verify(signed_params)
        .deep_transform_values { |value| value.is_a?(String) && value.start_with?("gid://") ? GlobalID::Locator.locate(value) : value }
    end

    def controller(signed_controller:)
      return ApplicationController unless signed_controller.present?

      message_verifier
        .verify(signed_controller)
        .yield_self { |controller_string| Kernel.const_get(controller_string) }
    end
  end
end
