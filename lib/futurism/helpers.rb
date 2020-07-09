module Futurism
  module Helpers
    def futurize(records, extends:, &block)
      placeholder = capture(&block)
      Array(records).map { |record|
        case extends
        when :tr
          content_tag :tr, placeholder, data: {sgid: record.to_sgid.to_s}, is: "futurism-table-row"
        else
          content_tag :"futurism-element", placeholder, data: {sgid: record.to_sgid.to_s}
        end
      }.join.html_safe
    end
  end
end
