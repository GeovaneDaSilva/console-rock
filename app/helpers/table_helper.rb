# :nodoc
module TableHelper
  def sortable(link_name, namespace, column, anchor = nil)
    new_params = params.permit!.merge(
      "#{namespace}_#{column}_sorted_by" => next_column_sort_dir(namespace, column),
      "#{namespace}_sort_columns"        => Array.wrap(params["#{namespace}_sorted_columns"])
                                                 .unshift(column).uniq
    ).except(:action, :controller)

    content_tag :a, href: "#{url_for(params: new_params)}#{anchor}" do
      safe_join(
        [
          content_tag(:i, nil, class: "fa fa-#{sort_icon_name(namespace, column)}"),
          " ",
          link_name
        ]
      )
    end
  end

  # Pick the next sort direction for the column
  def next_column_sort_dir(namespace, column)
    case params["#{namespace}_#{column}_sorted_by"]
    when "asc"
      "desc"
    when "desc"
      nil
    else
      "asc"
    end
  end

  def sort_icon_name(namespace, column)
    case params["#{namespace}_#{column}_sorted_by"]
    when "asc"
      "sort-asc"
    when "desc"
      "sort-desc"
    else
      "sort"
    end
  end
end
