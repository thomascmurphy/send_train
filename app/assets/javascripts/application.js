// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

//= require bootstrap-sprockets
//= require chartery

jQuery(function($){

  $('body').on('submit', 'form.ajax_form', function(e){
    e.preventDefault();
    var ajax_form = $(this),
    form_action = ajax_form.attr('action'),
    form_method = ajax_form.attr('method'),
    form_data = ajax_form.serializeArray();

    $.ajax({
      type: form_method,
      url: form_action,
      data: form_data,
      success: function(return_data){
        var form_wrapper = ajax_form.parent();
        if(form_wrapper.hasClass('editable_region')){
          ajax_form.find('a.edit_toggle').removeClass('submit_form').text('Edit');
          form_wrapper.toggleClass('editing');
        }
      }
    });
  });

	$('body').on('change, input', '.slider_container input[type="range"]', function(){
		var slider_container = $(this).closest('.slider_container');
		var show_value = $(this).val();
		var value_conversions_piped = $(this).data('value_conversions_piped');
		if(value_conversions_piped){
  		var value_conversions = value_conversions_piped.split('|');
  		if(value_conversions[show_value]){
    		show_value = value_conversions[show_value];
  		}
		}
		slider_container.find('span.slider_value').text(show_value);
	});

	$('body').on('click', 'a.edit_toggle', function(){
  	var editable_region = $(this).closest('.editable_region');
  	var editable_region_list_parent = editable_region.data('list_parent');
  	if($(this).hasClass('submit_form')){
    	editable_region.find('form').submit();
  	} else {
    	if(editable_region_list_parent && editable_region.closest(editable_region_list_parent).find('.editable_region.editing').length){
        editable_region.closest(editable_region_list_parent).find('.editable_region.editing a.edit_toggle').click();
    	}
    	$(this).addClass('submit_form').text('Save');
    	editable_region.toggleClass('editing');
  	}
	});

	$('body').on('click', 'a.delete_link', function(event){
  	event.preventDefault();
  	event.stopPropagation();
  	var editable_container = $(this).closest('.editable_container');
  	var delete_url = $(this).attr('href');
  	var delete_method = $(this).data('method');
  	$.ajax({
      type: delete_method,
      url: delete_url,
      success: function(return_data){
        editable_container.fadeOut(200, function(){
          $(this).remove();
        });
      }
    });


  });



});
