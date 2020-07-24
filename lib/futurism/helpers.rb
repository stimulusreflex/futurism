module Futurism
  module Helpers
    def futurize(records_or_string = nil, extends:, **options, &block)
      placeholder = capture(&block)

      if records_or_string.is_a?(ActiveRecord::Base) || records_or_string.is_a?(ActiveRecord::Relation)
        futurize_active_record(records_or_string, extends: extends, placeholder: placeholder, **options)
      elsif records_or_string.is_a?(String)
        futurize_with_options(extends: extends, partial: records_or_string, locals: options, placeholder: placeholder)
      else
        futurize_with_options(extends: extends, placeholder: placeholder, **options)
      end
    end

    def futurize_with_options(extends:, placeholder:, **options)
      collection = options.delete(:collection)
      if collection.nil?
        render_element(extends: extends, placeholder: placeholder, options: options)
      else
        collection_class_name = collection.first.class.name
        collection.map { |record|
          render_element(extends: extends, placeholder: placeholder, options: options.merge(locals: {collection_class_name.downcase.to_sym => record}))
        }.join.html_safe
      end
    end

    def futurize_active_record(records, extends:, placeholder:, **options)
      Array(records).map { |record|
        render_element(extends: extends, placeholder: placeholder, options: options.merge(model: record))
      }.join.html_safe
    end

    def render_element(extends:, options:, placeholder:)
      html_options = options.delete(:html_options) || {}
      options = options.delete(:model) || options
      case extends
      when :li
        content_tag :li, placeholder, {data: {signed_params: futurism_signed_params(options)}, is: "futurism-li"}.merge(html_options)
      when :tr
        content_tag :tr, placeholder, {data: {signed_params: futurism_signed_params(options)}, is: "futurism-table-row"}.merge(html_options)
      else
        content_tag :"futurism-element", placeholder, {data: {signed_params: futurism_signed_params(options)}}.merge(html_options)
      end
    end

    def futurism_signed_params(params)
      Rails.application.message_verifier("futurism").generate(params)
    end
  end
end
