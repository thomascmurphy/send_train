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

  $('body').on('click', '.disable_after_click', function(e){
    $(this).prop("disabled", true);
  });

  $('body').on('change, input', '.slider_container input[type="range"]', function(){
		var slider_container = $(this).closest('.slider_container');
		var show_value = $(this).val();
		slider_container.find('span.slider_value').text(show_value);
	});

  $('body').on('change', '.type_select', function(e){
    var boulder_grades = $(this).closest('form').find('.boulder_grades');
    var sport_grades = $(this).closest('form').find('.sport_grades');
    if ($(this).val() == "boulder" && boulder_grades.prop('disabled')) {
      boulder_grades.toggleClass('hidden').prop('disabled', false);
      sport_grades.toggleClass('hidden').prop('disabled', true);
    } else if ($(this).val() == "sport" && sport_grades.prop('disabled')) {
      boulder_grades.toggleClass('hidden').prop('disabled', true);
      sport_grades.toggleClass('hidden').prop('disabled', false);
    } else if ($(this).val() == "trad" && sport_grades.prop('disabled')) {
      boulder_grades.toggleClass('hidden').prop('disabled', true);
      sport_grades.toggleClass('hidden').prop('disabled', false);
    }
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

});
