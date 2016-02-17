var climbs_ready;
climbs_ready = function() {

  $('#climb_modal').on('change', '.climb_type_select', function(e){
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

}

$(document).ready(climbs_ready);
$(document).on('page:load', climbs_ready);
