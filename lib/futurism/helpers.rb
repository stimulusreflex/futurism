module Futurism
  module Helpers
    def futurize(records, extends:, &block)
      placeholder = capture(&block)
      Array(records).map { |record|
        case extends
        when :tr
          content_tag :tr, placeholder, data: {signed_params: futurism_signed_params(record)}, is: "futurism-table-row"
        else
          content_tag :"futurism-element", placeholder, data: {signed_params: futurism_signed_params(record)}
        end
      }.join.html_safe
    end

    def futurism_signed_params(params)
      Rails.application.message_verifier("futurism").generate(params)
    end
  end
end
