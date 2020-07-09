module Futurism
  class Channel < ActionCable::Channel::Base
    include CableReady::Broadcaster

    def subscribed
      stream_from "FuturismChannel"
    end

    def receive(data)
      resources = data["sgids"].map { |sgid|
        [sgid, GlobalID::Locator.locate_signed(sgid)]
      }

      resources.each do |sgid, resource|
        cable_ready["FuturismChannel"].outer_html(
          selector: "[data-sgid='#{sgid}']",
          html: ApplicationController.render(resource)
        )
      end

      cable_ready.broadcast
    end
  end
end
