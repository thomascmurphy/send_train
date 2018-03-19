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
//= require jquery-ui
//= require turbolinks
//= require_tree .

//= require bootstrap-sprockets
//= require jquery-hotkeys
//= require bootstrap-wysiwyg
//= require chartery
//= require touch-punch

var ready;
ready = function() {

  $('body').on('click', '.disable_after_click', function(e){
    if ($(this).attr('type') == "submit") {
      $(this).closest('form').submit();
    }
    $(this).attr("disabled", "disabled");
  });

  $('body').on('click', '.spin_after_click', function(e){
    $(this).find('.glyphicon').removeClass('hidden').addClass('spinning');
  });

  $('.disable_after_click_remote').on("ajax:success", function(){
      $(this).attr("disabled", "disabled");
  });

  $('body').on('click', '.disable_click', function(e){
    e.preventDefault();
    return false;
  });

  $('body').on('change, input', '.slider_container input[type="range"]', function(){
		var slider_container = $(this).closest('.slider_container');
		var show_value = $(this).val();
		slider_container.find('span.slider_value').text(show_value);
	});

  $('body').on('click', '.selectable_items .add_selected_item', function() {
    var selectable_form = $(this).closest('form');
    var add_html = (
      $(this).closest('tr').html()
      .replace('Add', 'Remove')
      .replace('btn-success', 'btn-danger')
      .replace('add_selected_item', 'remove_selected_item')
    );
    $('.selected_items tbody').append('<tr>' + add_html + '</tr>');
    var existing_ids = selectable_form.find('.selected_ids').val();
    existing_ids += " " + $(this).data('item-id');
    selectable_form.find('.selected_ids').val(existing_ids);
  });

  $('body').on('click', '.selected_items .remove_selected_item', function() {
    var selectable_form = $(this).closest('form');
    $(this).closest('tr').remove();
    var existing_ids = selectable_form.find('.selected_ids').val();
    var substring_start = existing_ids.lastIndexOf($(this).data('item-id'));
    if (substring_start == 0) {
      existing_ids = existing_ids.substring($(this).data('item-id').toString().length + 1);
    } else if (substring_start > 0) {
      existing_ids = existing_ids.substring(0,substring_start - 1) + existing_ids.substring(substring_start + $(this).data('item-id').toString().length);
    }
    selectable_form.find('.selected_ids').val(existing_ids);
  });

  $('body').on('change', '.onsight_checkbox, .flash_checkbox', function() {
    if ($(this).val()) {
      var attempt_form = $(this).closest('form');
      attempt_form.find('.completion_slider').val(100).trigger('input');
    }
  });

  $('body').on('click', '.remove_table_row', function(){
    $(this).closest('tr').hide(400, function(){
      $(this).remove();
    });
  });

  $('[data-toggle="tooltip"]').tooltip();

  $('body').on('click', '.image_field_container .remove_image', function() {
    $(this).hide();
    $(this).siblings('.image_field').first().val('');
    $(this).siblings('.img-thumbnail').addClass('hidden');
    //$('.photoPreview').css('background', '');
    $(this).siblings('.image_form-group').first().removeClass('hidden');
    $(this).siblings('.remove_image_checkbox').prop('checked', true);
  });

  // $('#wysiwyg_editor').wysiwyg({
	// 	'form':
	// 	{
	// 		'text-field': 'wysiwyg_body',
	// 		'seperate-binary': false
	// 	}
  // });

}

$(document).ready(ready);
$(document).on('page:load', ready);
