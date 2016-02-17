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

}

$(document).ready(events_ready);
$(document).on('page:load', events_ready);
