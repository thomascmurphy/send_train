var macrocycles_ready;
macrocycles_ready = function() {

  var update_workout_ids = function(day) {
    var workout_ids = day.find('.planner_workout').map(function(){
      return $(this).data('workout-id');
    }).get();
    day.find('.workout_ids').val(workout_ids.join(" "));

    var macrocycle_workout_ids = day.find('.planner_workout').map(function(){
      return $(this).data('macrocycle-workout-id');
    }).get();
    day.find('.macrocycle_workout_ids').val(macrocycle_workout_ids.join(" "));
  };

  var draggable_options = {
    appendTo: "body",
    helper: "clone",
    cursor: "pointer",
    start : function(event, ui) {
       ui.helper.width($('.calendar .calendar_day').width());
    }
  };

  var droppable_options = {
    activeClass: "",
    hoverClass: "translucent",
    accept: ":not(.ui-sortable-helper)",
    drop: function( event, ui ) {
      var workout_block = ui.draggable[0];
      $(workout_block.outerHTML).appendTo( this );
      update_workout_ids($(this));
    }
  };

  var sortable_options = {
    items: ".planner_workout",
    connectWith: ".calendar_day",
    sort: function() {
      // gets added unintentionally by droppable interacting with sortable
      // using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
      //$( this ).removeClass( "" );
    },
    stop: function( event, ui ) {
      update_workout_ids($(this));
    },
    remove: function( event, ui ) {
      update_workout_ids($(this));
    },
    receive: function( event, ui ) {
      update_workout_ids($(this));
    }
  };

  $('.calendar.droppable').on('click', '.calendar_day .planner_workout .close', function() {
    var calendar_day = $(this).closest('.calendar_day');
    var planner_workout = $(this).closest('.planner_workout');
    planner_workout.remove();
    update_workout_ids(calendar_day);
  });

  $('.calendar.droppable .calendar_week .calendar_day').droppable(droppable_options).sortable(sortable_options);

  $('#my_workouts .planner_workout').draggable(draggable_options);

  $('.calendar.droppable .calendar_week .calendar_day').each(function() {
    update_workout_ids($(this));
  });

  $('.calendar_add_week').click(function() {
    var count = $('.calendar .calendar_week').length + 1;
    var new_week = $('<div class="row row-eq-height calendar_week" data-week=' + count + '></div>');
    for (i=1; i<=7; i++) {
      var day = $('<div class="col-xs-1 calendar_day"><input type="hidden" name="weeks[' + count + ']days[' + i + ']workouts[][id]" class="workout_ids"/></div>');
      day.droppable(droppable_options).sortable(sortable_options).appendTo(new_week);
    }

    new_week.appendTo( '.calendar' );


  });

}

$(document).ready(macrocycles_ready);
$(document).on('page:load', macrocycles_ready);
