Deface::Override.new(
  virtual_path: "spree/admin/users/_sidebar",
  name: "admin_user_sidebar_log_entries",
  insert_bottom: "[data-hook='admin_user_tab_options']",
  text: "<li><%= link_to 'Log Entries', admin_log_entries_path(source_type: 'Spree::User', source_id: @user.id) %></li>",
)
