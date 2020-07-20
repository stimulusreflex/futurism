module Futurism
  module Helpers
    def futurize(records_or_string = nil, extends:, **options, &block)
      placeholder = capture(&block)

      if records_or_string.is_a?(ActiveRecord::Base) || records_or_string.is_a?(ActiveRecord::Relation)
        futurize_active_record(records_or_string, extends: extends, placeholder: placeholder)
      elsif records_or_string.is_a?(String)
        futurize_with_options(extends: extends, partial: records_or_string, locals: options, placeholder: placeholder)
      else
        futurize_with_options(extends: extends, placeholder: placeholder, **options)
      end
    end

    def futurize_with_options(extends:, placeholder:, **options)
      case extends
      when :tr
        content_tag :tr, placeholder, data: {signed_params: futurism_signed_params(options)}, is: "futurism-table-row"
      else
        content_tag :"futurism-element", placeholder, data: {signed_params: futurism_signed_params(options)}
      end
    end

    def futurize_active_record(records_or_string, extends:, placeholder:)
      Array(records_or_string).map { |record|
        case extends
        when :tr
          content_tag :tr, placeholder, data: {signed_params: futurism_signed_params(record)}, is: "futurism-table-row"
        else
          content_tag :"futurism-element", placeholder, data: {signed_params: futurism_signed_params(record)}
        end
      }.join.html_safe
    end

    def futurism_signed_params(params)
      Rails.application.message_verifier("futurism").generate(params, expires_in: 1.hour)
    end
  end
end
