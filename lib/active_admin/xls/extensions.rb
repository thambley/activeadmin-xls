ActiveAdmin.before_load do
  require 'active_admin/xls/dsl'
  require 'active_admin/xls/resource_extension'
  require 'active_admin/xls/resource_controller_extension'

  ActiveAdmin::Views::PaginatedCollection.add_format :xls

  ActiveAdmin::ResourceDSL.send :include, ActiveAdmin::Xls::DSL
  ActiveAdmin::Resource.send :include, ActiveAdmin::Xls::ResourceExtension
  ActiveAdmin::ResourceController.send(
    :prepend,
    ActiveAdmin::Xls::ResourceControllerExtension
  )
end
