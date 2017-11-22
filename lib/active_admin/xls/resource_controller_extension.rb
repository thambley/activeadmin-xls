module ActiveAdmin
  module Xls
    module ResourceControllerExtension
      def self.included(base)
        base.send :alias_method_chain, :per_page, :xls
        base.send :alias_method_chain, :index, :xls
        base.send :alias_method_chain, :rescue_active_admin_access_denied, :xls
        base.send :respond_to, :xls
      end

      def index_with_xls
        index_without_xls do |format|
          yield format if block_given?

          format.xls do
            xls = active_admin_config.xls_builder.serialize(collection,
                                                            view_context)
            send_data(xls,
                      filename: xls_filename,
                      type: Mime::Type.lookup_by_extension(:xls))
          end
        end
      end

      def rescue_active_admin_access_denied_with_xls(exception)
        if request.format == Mime::Type.lookup_by_extension(:xls)
          respond_to do |format|
            format.xls do
              flash[:error] = "#{exception.message} Review download_links in initializers/active_admin.rb"
              redirect_backwards_or_to_root
            end
          end
        else
          rescue_active_admin_access_denied_without_xls(exception)
        end
      end

      # patch per_page to use the CSV record max for pagination
      # when the format is xls
      def per_page_with_xls
        if request.format == Mime::Type.lookup_by_extension(:xls)
          return max_per_page if respond_to?(:max_per_page, true)
          active_admin_config.max_per_page
        end

        per_page_without_xls
      end

      # Returns a filename for the xls file using the collection_name
      # and current date such as 'my-articles-2011-06-24.xls'.
      def xls_filename
        timestamp = Time.now.strftime('%Y-%m-%d')
        "#{resource_collection_name.to_s.tr('_', '-')}-#{timestamp}.xls"
      end
    end
  end
end
