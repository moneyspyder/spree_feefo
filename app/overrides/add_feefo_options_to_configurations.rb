Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_feefo_options_to_configurations',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  partial: 'spree/admin/shared/sub_menu/feefo_options'
)
