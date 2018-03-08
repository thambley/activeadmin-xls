module ActiveAdmin
  module Xls
    # Extends the resource controller to respond to xls requests
    module ResourceControllerExtension
      def self.prepended(base)
        base.send :respond_to, :xls, only: :index
      end

      # Patches index to respond to requests with xls mime type by
      # sending a generated xls document serializing the current
      # collection
      def index
        super do |format|
          format.xls do
            xls = active_admin_config.xls_builder.serialize(xls_collection,
                                                            view_context)
            send_data(xls,
                      filename: xls_filename,
                      type: Mime::Type.lookup_by_extension(:xls))
          end

          yield(format) if block_given?
        end
      end

      # Patches rescue_active_admin_access_denied to respond to xls
      # mime type. Provides administrators information on how to
      # configure activeadmin to respond propertly to xls requests
      #
      # param exception [Exception] unauthorized access error
      def rescue_active_admin_access_denied(exception)
        if request.format == Mime::Type.lookup_by_extension(:xls)
          respond_to do |format|
            format.xls do
              flash[:error] = "#{exception.message} Review download_links in initializers/active_admin.rb"
              redirect_backwards_or_to_root
            end
          end
        else
          super(exception)
        end
      end

      # Returns a filename for the xls file using the collection_name
      # and current date such as 'my-articles-2011-06-24.xls'.
      #
      # @return [String] with default filename
      def xls_filename
        timestamp = Time.now.strftime('%Y-%m-%d')
        "#{resource_collection_name.to_s.tr('_', '-')}-#{timestamp}.xls"
      end

      # Returns the collection to use when generating an xls file.
      def xls_collection
        find_collection except: :pagination
      end
    end
  end
end
