$(document).ready ->
  #handle edit click
  $('a.edit-subscription-item').click toggleSubscriptionItemEdit

  #handle cancel click
  $('a.cancel-subscription-item').click toggleSubscriptionItemEdit

  #handle save click
  $('a.save-subscription-item').click ->
    save = $ this
    subscription_item_id = save.data('subscription-item-id')
    quantity = parseInt(save.parents('tr').find('input.subscription_item_quantity').val())

    toggleItemEdit()
    adjustSubscriptionItem(subscription_item_id, quantity)
    false

  # handle delete click
  $('a.delete-subscription-item').click ->
    if confirm(Spree.translations.are_you_sure_delete)
      del = $(this);
      subscription_item_id = del.data('subscription-item-id');

      toggleItemEdit()
      deleteSubscriptionItem(subscription_item_id)

toggleSubscriptionItemEdit = ->
  link = $(this);
  link.parent().find('a.edit-subscription-item').toggle();
  link.parent().find('a.cancel-subscription-item').toggle();
  link.parent().find('a.save-subscription-item').toggle();
  link.parent().find('a.delete-subscription-item').toggle();
  link.parents('tr').find('td.subscription-item-qty-show').toggle();
  link.parents('tr').find('td.subscription-item-qty-edit').toggle();

  false

subscriptionItemURL = (subscription_item_id) ->
  #url = Spree.pathFor('api/subscription') + "/" + subscription_id + "/subscription_items/" + subscription_item_id + ".json"
  url = Spree.pathFor('api/subscription_items') + "/" + subscription_item_id + ".json"

adjustSubscriptionItem = (subscription_item_id, quantity) ->
  url = subscriptionItemURL(subscription_item_id)
  $.ajax(
    type: "PUT",
    url: Spree.url(url),
    data:
      subscription_item:
        quantity: quantity
      token: Spree.api_key
  ).done (msg) ->    
    show_flash 'success', 'Successfully updated the quantity.'
    $('.subscription-item-qty-show').text(quantity)
    $('a.edit-subscription-item').trigger 'click'

deleteSubscriptionItem = (subscription_item_id) ->
  url = lineItemURL(subscription_item_id)
  $.ajax(
    type: "DELETE"
    url: Spree.url(url)
    data:
      token: Spree.api_key
  ).done (msg) ->
    $('#subscription-item-' + subscription_item_id).remove()
    if $('.subscription-items tr.subscription-item').length == 0
      $('.subscription-items').remove()
