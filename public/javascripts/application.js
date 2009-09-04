// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
(function($) {
  $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
  
  $.authenticityToken = function() {
    return $('#authenticity-token').attr('content');
  };
  
  $(document).ajaxSend(function(event, request, settings) {
    if (settings.type == 'post') {
      settings.data = (settings.data ? settings.data + "&" : "")
          + "authenticity_token=" + encodeURIComponent($.authenticityToken());
      request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    }
  });
  
  $.fn.toggleCheckbox = function(target) {
    return this.each(function() {
      $(target)[this.checked ? 'show' : 'hide']();
    });
  };

  $('a.destroy').live('click', function(event) {
    event.preventDefault();
	event.stopPropogation();
    if (confirm('Are you sure you want to delete?')) {
      var form = $('<form method="POST"></form>')
        .css({display:'none'})
        .attr('action', this.href)
        .append('<input type="hidden" name="_method" value="delete"/>')
        .append('<input type="hidden" name="authenticity_token" value="' +
          $.authenticityToken() + '"/>')
        .insertAfter(this.parentNode);
      form.submit();
    }
  });
})(jQuery);

jQuery(function($) {
  $('#health_professional').toggleCheckbox('#health_professional_fields').click(function() {
    $(this).toggleCheckbox('#health_professional_fields');
    $('fieldset#health_professional_fields *:input').val('');
  });
  
  $('select.crossSelect[multiple="multiple"]').crossSelect({clickSelects: true});
  
  $("#alert_user_ids").fcbkcomplete({
    json_url: '/search',
    json_cache: true,
    filter_case: false,
    filter_hide: true,
    filter_selected: true,
    firstselected: true,
    newel: true
  });

  $("#role_assigns_user_ids").fcbkcomplete({
    json_url: '/search',
    json_cache: true,
    filter_case: false,
    filter_hide: true,
    filter_selected: true,
    firstselected: true,
    newel: true
  });
});

jQuery(function($) {
  $('.alert .summary').click(function(){
    $(this).parent(".alert").children(".detail").toggle();
  });
});

 $(document).ready(function() {
	var name_synched = false;

	if($('#user_display_name').val().trim() == "" || $('#user_display_name').val() == ($('#user_first_name').val().trim() + " " + $('#user_last_name').val().trim()).trim()) name_synched = true;

	display_name_change = function(){
		if (name_synched) {
			$('#user_display_name').val(($('#user_first_name').val().trim() + " " + $('#user_last_name').val().trim()).trim())
		}
		if($('#user_display_name').val().trim() == "" || $('#user_display_name').val() == ($('#user_first_name').val().trim() + " " + $('#user_last_name').val().trim()).trim()) name_synched = true;
		else name_synched = false;
	}

	$('#user_first_name').keyup(display_name_change)
	$('#user_last_name').keyup(display_name_change)
	$('#user_display_name').keyup(function() {
		if($('#user_display_name').val().trim() == "" || $('#user_display_name').val() == ($('#user_first_name').val().trim() + " " + $('#user_last_name').val().trim()).trim()) name_synched = true;
		else name_synched = false;
	});
});
