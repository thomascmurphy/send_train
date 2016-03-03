var profile_ready;
profile_ready = function() {

  var donut_options = function(superior){
    var main_color = '#FF9800';
    if (superior) {
      main_color = '#00BCD4';
    }
    var return_options = {
      colors: [
        main_color,
        '#EFEFEF'],
      donut_thickness: '10%',
      full_donut: false,
      rounded: true
    };
    return return_options;
  };


  $('.build_donut').each(function(){
    var user_value = parseFloat($(this).data('user-value'));
    var comparison_value = parseFloat($(this).data('comparison-value'));
    var donut_data = [{
      name: $(this).data('summoner-name'),
      value: user_value
    }];
    var specific_donut_options = {
      title: $(this).data('chart-title'),
      goal_value: user_value + comparison_value,
      goal_value_text: $(this).data('comparison-title'),
      number_decorator: $(this).data('number-decorator')
    };
    var superior = user_value >= comparison_value;
    if ($(this).data('inverse-superiority')) {
      superior = user_value <= comparison_value;
    }
    $(this).drawDonut(donut_data, $.extend(specific_donut_options, donut_options(superior)));
  });

  var line_options = {
      colors: [
          '#00BCD4',
          '#FF9800',
          '#5cb85c',
          '#d9534f'],
      has_key: false,
      hover: true
  };

  $('.build_line').each(function(){
    var line_data = [];
    var primary_title = $(this).data('primary-title');
    var primary_data = [];
    var i = 0;
    while(typeof $(this).data('primary-value-' + i) != "undefined") {
      var point_value = {name: $(this).data('primary-name-' + i),
                         value: $(this).data('primary-value-' + i)}
      if (typeof $(this).data('primary-tooltip-value-' + i) != "undefined") {
        point_value['tooltip_value'] = $(this).data('primary-tooltip-value-' + i);
      }
      primary_data.push(point_value);
      i++;
    }
    if (primary_data.length > 0) {
      line_data.push(primary_data);
    }

    var comparison_title = $(this).data('comparison-title');
    var comparison_data = [];
    i = 0;
    while(typeof $(this).data('comparison-value-' + i) != "undefined") {
      var point_value = {name: $(this).data('comparison-name-' + i),
                         value: $(this).data('comparison-value-' + i)}
      if (typeof $(this).data('comparison-tooltip-value-' + i) != "undefined") {
        point_value['tooltip_value'] = $(this).data('comparison-tooltip-value-' + i);
      }
      comparison_data.push(point_value);
      i++;
    }
    if (primary_data.length > 0) {
      line_data.push(comparison_data);
    }
    var specific_line_options = {
      title: $(this).data('chart-title'),
      zoom_y: 0.75
    };
    $(this).drawLine(line_data, $.extend(specific_line_options, line_options));
  });

  $('.build_many_lines').each(function(){
    var full_line_data = [];
    var raw_data = $(this).data('line-data');
    for (var name in raw_data) {
      if (!raw_data.hasOwnProperty(name)) continue;
      var line_data = [];
      var capital_name = name.charAt(0).toUpperCase() + name.slice(1);
      for (var i=0; i<raw_data[name].length; i++) {
        raw_data[name][i]
        var point_value = {name: capital_name + " " + raw_data[name][i]["date"],
                           value: raw_data[name][i]["value"]};
        line_data.push(point_value);
      }
      full_line_data.push(line_data);
    }
    var specific_line_options = {
      title: $(this).data('chart-title'),
      zoom_y: 0.75
    };
    $(this).drawLine(full_line_data, $.extend(specific_line_options, line_options));
  });

}



$(document).ready(profile_ready);
$(document).on('page:load', profile_ready);
