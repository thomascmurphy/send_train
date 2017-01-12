module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_by ? "current #{sort_direction}" : nil
    direction = column == sort_by && sort_direction == "asc" ? "desc" : "asc"
    title_text = column == sort_by ? raw("#{title} <span class='small glyphicon glyphicon-triangle-#{sort_direction == 'asc' ? 'top' : 'bottom'}'></span> ") : title
    link_to title_text, {:sort_by => column, :sort_direction => direction}, {:class => css_class}
  end

end
