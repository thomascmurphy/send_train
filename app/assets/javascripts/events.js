var events_ready;
events_ready = function() {

  $('#event_modal').on('change', '.workout_select', function() {
    if ($(this).val() != "") {
      $('#event_modal .macrocycle_select').val("").prop({disabled: true});
    } else {
      $('#event_modal .macrocycle_select').prop({disabled: false});
    }
  });

  $('#event_modal').on('change', '.macrocycle_select', function() {
    if ($(this).val() != "") {
      $('#event_modal .workout_select').val("").prop({disabled: true});
    } else {
      $('#event_modal .workout_select').prop({disabled: false});
    }
  });

  $('.build_skew').each(function(){
    var skew_data = [{
      title: $(this).data('chart-title'),
      values: $(this).data('skew-data')
    }];
    var specific_skew_options = {
        colors: [
            '#00BCD4'],
        border_color: '#999999',
        has_key: false,
        categories: true,
        categories_colors: ['#d9534f', '#FF9800', '#FDD835', '#5cb85c'],
        data_max: $(this).data('data-max')
    };
    $(this).drawSkew(skew_data, specific_skew_options);
  });

}

$(document).ready(events_ready);
$(document).on('page:load', events_ready);
