module Futurism
  module Helpers
    def futurize(records, extends:, **options, &block)
      placeholder = capture(&block)
      Array(records).map { |record|
        case extends
        when :tr
          content_tag :tr, placeholder, {data: {sgid: record.to_sgid.to_s}, is: "futurism-table-row"}.merge(options)
        else
          content_tag :"futurism-element", placeholder, {data: {sgid: record.to_sgid.to_s}}.merge(options)
        end
      }.join.html_safe
    end
  end
end
