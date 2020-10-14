module Futurism
  module Resolver
    class Controller
      def self.from(signed_string:)
        if signed_string.present?
          Futurism::MessageVerifier
            .message_verifier
            .verify(signed_string)
            .to_s
            .safe_constantize
        else
          Futurism.default_controller
        end
      end
    end
  end
end
