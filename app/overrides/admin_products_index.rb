Deface::Override.new(virtual_path: 'spree/admin/products/index', 
                    name: 'subscribable_in_header', 
                    insert_before: "[data-hook='admin_products_index_header_actions']", 
                    text: "<th><%= sort_link @search, :subscribable, t(:subscribable) %></th>"
                    )

Deface::Override.new(virtual_path: 'spree/admin/products/index', 
                    name: 'subscribable_in_rows', 
                    insert_before: "[data-hook='admin_products_index_row_actions']", 
                    text: "<td><%= product.subscribable %></td>"
                    )
Deface::Override.new(virtual_path: 'spree/admin/products/_form', 
                    name: 'subscribable_field', 
                    insert_bottom: "[data-hook='admin_product_form_right']", 
                    text: "<div class='omega two columns'>
                            <%= f.field_container :subscribable, :class => ['checkbox'] do %>
                              <label>
                                <%= f.check_box :subscribable %>
                                <%= t(:subscribable) %>
                              </label>
                            <% end %>
                          </div>"
                    )
