module Futurism
  module MessageVerifier
    private

    def message_verifier
      @message_verifier ||= Rails.application.message_verifier("futurism")
    end
  end
end