module Futurism
  module MessageVerifier
    def self.message_verifier
      @message_verifier ||= Rails.application.message_verifier("futurism")
    end

    def message_verifier
      @message_verifier ||= Rails.application.message_verifier("futurism")
    end
  end
end
