Deface::Override.new(:virtual_path => "spree/admin/shared/_menu",
                     :name => "subscriptions_admin_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => "<%= tab(:subscriptions) %>")

Deface::Override.new(:virtual_path => "spree/admin/shared/_content_header",
                     :name => "admin_subscriptions_failures",
                     :insert_top => "[data-hook='toolbar']>ul",
                     :text => "<li><%= link_to('Failed Renewals', failures_admin_subscriptions_path, class: 'button fa') %></li>"
                     )