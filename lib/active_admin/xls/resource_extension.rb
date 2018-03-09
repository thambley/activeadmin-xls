module ActiveAdmin
  # Provides xls functionality to ActiveAdmin resources
  module Xls
    # Extends ActiveAdmin Resource
    module ResourceExtension
      # Sets the XLS Builder
      #
      # @param builder [Builder] the new builder object
      # @return [Builder] the builder for this resource
      def xls_builder=(builder)
        @xls_builder = builder
      end

      # Returns the XLS Builder. Creates a new Builder if none exists.
      #
      # @return [Builder] the builder for this resource
      #
      # @example Localize column headers
      #   # app/admin/posts.rb
      #   ActiveAdmin.register Post do
      #     config.xls_builder.i18n_scope = [:active_record, :models, :posts]
      #   end
      def xls_builder
        @xls_builder ||= ActiveAdmin::Xls::Builder.new(resource_class)
      end
    end
  end
end
