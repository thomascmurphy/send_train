var workouts_ready;
workouts_ready = function() {

  var build_new_row = function(exercise) {
    var exercise_name = $(exercise).find('span.exercise_label').html();
    var exercise_metrics = $(exercise).find('div.exercise_metrics').html();
    var new_row_html = '<tr><td>' + exercise_name +'</td>'
      + '<td>' + exercise_metrics + '</td>'
      + '<td class="text-right"><input class="form-control inline_block" type="number" name="workout_exercises[][reps]" value="1"/></td>'
      + '<td class="text-right"><a href="javascript:void(0);" class="remove_table_row btn btn-danger">Remove</a></td>';
    return new_row_html;
  };

  var draggable_options = {
    appendTo: "body",
    helper: "clone",
    cursor: "-webkit-grabbing",
    start : function(event, ui) {
       ui.helper.width($(this).width());
    }
  };

  var droppable_options = {
    activeClass: "",
    hoverClass: "translucent",
    accept: ":not(.ui-sortable-helper)",
    drop: function( event, ui ) {
      var exercise_block = ui.draggable[0];
      var push_row = $(this).find('tbody .push_row');
      var new_row_html = build_new_row(exercise_block);
      $(new_row_html).insertBefore(push_row);
      $(this).find('tbody tr.placeholder_row').remove();
    }
  };

  var fixHelper = function(e, ui) {
    ui.children().each(function() {
      $(this).width($(this).width());
    });
    return ui;
  };

  var sortable_options = {
    items: "tr:not(.push_row)",
    helper: fixHelper,
    sort: function() {
      // gets added unintentionally by droppable interacting with sortable
      // using connectWithSortable fixes this, but doesn't allow you to customize active/hoverClass options
      //$( this ).removeClass( "" );
    },
    stop: function( event, ui ) {

    },
    remove: function( event, ui ) {

    },
    receive: function( event, ui ) {

    }
  };

  $('.exercise_list').droppable(droppable_options);
  $('.exercise_list tbody').sortable(sortable_options);

  $('#my_exercises .planner_exercise').draggable(draggable_options);

}

$(document).ready(workouts_ready);
$(document).on('page:load', workouts_ready);
