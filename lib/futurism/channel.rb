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
      resources = data.fetch_values("signed_params", "sgids", "signed_controllers", "urls") { |_key| Array.new(data["signed_params"].length, nil) }.transpose

      resources.each do |signed_params, sgid, signed_controller, url|
        selector = "[data-signed-params='#{signed_params}']"
        selector << "[data-sgid='#{sgid}']" if sgid.present?

        controller = Resolver::Controller.from(signed_string: signed_controller)
        renderer = Resolver::Controller::Renderer.for(controller: controller,
                                                      connection: connection,
                                                      url: url,
                                                      params: @params)

        resource = lookup_resource(signed_params: signed_params, sgid: sgid)
        html = renderer.render(resource)

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
  end
end
