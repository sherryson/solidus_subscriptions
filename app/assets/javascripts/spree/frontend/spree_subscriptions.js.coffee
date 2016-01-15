$(document).ready ->
  #handle edit click
  $('.change-resume-subscription-on').click toggleResumeSubscriptionOn

toggleResumeSubscriptionOn = ->
  link = $(this);
  link.parents('tr').find('div.resume-subscription-on').toggle();
  link.parents('tr').find('div.subscription-will-resume-on').toggle();
