var exercises_ready;
exercises_ready = function() {
  $('body').on('click', '.exercise_metric_list .add_expense_metric', function(){
    var table = $(this).closest('.exercise_metric_list');
    var button_row = $(this).closest('tr.add_metric_button_row');
    var new_row_html = table.find('.metric_template_row').html();
    $('<tr>' + new_row_html + '</tr>').insertBefore(button_row);
    var new_option_button_row_html = table.find('.add_option_button_template_row').html();
    $('<tr class="add_option_button_row" style="display: none;">' + new_option_button_row_html + '</tr>').insertBefore(button_row);
  });

  $('body').on('click', '.exercise_metric_list .add_expense_metric_option', function(){
    var table = $(this).closest('.exercise_metric_list');
    var button_row = $(this).closest('tr');
    var new_row_html = table.find('.option_template_row').html();
    $('<tr class="options_row">' + new_row_html + '</tr>').insertBefore(button_row);
  });

  $('body').on('change', '.exercise_metric_list select.metric_type_select', function() {
    var table = $(this).closest('.exercise_metric_list');
    var metric_row = $(this).closest('tr');
    var type_value = $(this).val();
    metric_row.nextAll('tr').each(function(){
      if ($(this).hasClass('options_row') || $(this).hasClass('add_option_button_row')) {
        if (type_value == 5) {
          $(this).show();
        } else {
          $(this).hide();
        }
      } else {
        return false;
      }
    });
    if (type_value==1 || type_value==2 || type_value==3 || type_value==8 || type_value==10) {
      metric_row.find('.default_value').show().prop('disabled', false);
    } else {
      metric_row.find('.default_value').hide().prop('disabled', true);
    }
  });

}

$(document).ready(exercises_ready);
$(document).on('page:load', exercises_ready);
