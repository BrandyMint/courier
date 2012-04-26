$('a.toggle-subscription-link').live('click', function(evt, data, status, xhr){
  // TODO asset_url и подгружать картинку заранее
  $(this).parent().append('<img src="/assets/hspinner.gif" class="hspinner" alt="в процессе.."/>');
  $(this).hide();
}).live('ajax:success', function(evt, data, status, xhr){
  $(this).parent('.toggle-subscription').html(data['html']);
}).live('ajax:error', function(evt, xhr, status, error){
  alert('Error!');
});
