module ActiveAdmin
  module Xls
    module ResourceControllerExtension
      def self.prepended(base)
        base.send :respond_to, :xls
      end

      def index(&block)
        super do |format|
          block.call format if block_given?

          format.xls do
            xls = active_admin_config.xls_builder.serialize(collection, view_context)
            send_data(xls,
                      :filename => "#{xls_filename}",
                      :type => Mime::Type.lookup_by_extension(:xls))
          end
        end
      end

      # patching per_page to use the CSV record max for pagination when the format is xls
      def per_page
        if request.format ==  Mime::Type.lookup_by_extension(:xls)
          return respond_to?(:max_per_page, true) ? max_per_page : active_admin_config.max_per_page
        end

        super
      end

      # Returns a filename for the xls file using the collection_name
      # and current date such as 'my-articles-2011-06-24.xls'.
      def xls_filename
        "#{resource_collection_name.to_s.gsub('_', '-')}-#{Time.now.strftime("%Y-%m-%d")}.xls"
      end
    end
  end
end
