module Futurism
  class Channel < ActionCable::Channel::Base
    include CableReady::Broadcaster

    def subscribed
      stream_from "Futurism::Channel"
    end

    def receive(data)
      resources = data.fetch_values("signed_params", "sgids") { |key| [nil] }.transpose

      new_env = connection.env.merge(ApplicationController.renderer.instance_variable_get(:@env))
      ApplicationController.renderer.instance_variable_set(:@env, new_env)

      resources.each do |signed_params, sgid|
        selector = "[data-signed-params='%s'%s]" % [signed_params, sgid.present? ? " data-sgid='#{sgid}'" : ""]
        cable_ready["Futurism::Channel"].outer_html(
          selector: selector,
          html: ApplicationController.render(resource(signed_params: signed_params, sgid: sgid))
        )
      end

      cable_ready.broadcast
    end

    private

    def resource(signed_params:, sgid:)
      return GlobalID::Locator.locate_signed(sgid) if sgid.present?

      Rails.application.message_verifier("futurism").verify(signed_params)
    end
  end
end
