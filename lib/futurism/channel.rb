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
      resources = data.fetch_values("signed_params", "sgids", "signed_controllers", "urls") { |_key| Array.new(data["signed_params"].length, nil) }.transpose

      resolver = Resolver::Resources.new(resource_definitions: resources, connection: connection, params: @params)
      resolver.resolve do |selector, html|
        cable_ready[stream_name].outer_html(
          selector: selector,
          html: html
        )
      end

      cable_ready.broadcast
    end
  end
end
