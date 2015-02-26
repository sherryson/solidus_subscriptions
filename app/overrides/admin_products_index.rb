# Deface::Override.new(virtual_path: 'spree/admin/products/index', 
#                     name: 'subscribable_in_header', 
#                     insert_before: "[data-hook='admin_products_index_header_actions']", 
#                     text: "<th><%= sort_link @search, :subscribable, t(:subscribable) %></th>"
#                     )

# Deface::Override.new(virtual_path: 'spree/admin/products/index', 
#                     name: 'subscribable_in_rows', 
#                     insert_before: "[data-hook='admin_products_index_row_actions']", 
#                     text: "<td><%= product.subscribable? %></td>"
#                     )

