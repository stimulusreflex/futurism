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
          default_controller
        end
      end

      def self.default_controller
        Futurism.default_controller || ::ApplicationController
      end
    end
  end
end
