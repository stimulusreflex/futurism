module Futurism
  module MessageVerifier
    def self.message_verifier
      @message_verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.key_generator.generate_key("futurism/verifier_key"), digest: "SHA256", serializer: Marshal)
    end

    def message_verifier
      @message_verifier ||= Futurism::MessageVerifier.message_verifier
    end
  end
end
