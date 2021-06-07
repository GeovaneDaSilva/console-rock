# Make a db query sortable from UI input
# Prevents passing user input to SQL queries
module Sortable
  extend ActiveSupport::Concern

  class_methods do
    def sortable(namespace, *columns)
      define_method("#{namespace}_sort_by_clause") do
        sort_by_query_clause(namespace)
      end

      define_method("#{namespace}_sort_columns") do
        sort_columns(namespace, columns)
      end

      define_method("#{namespace}_dir_for_column") do |column|
        dir_for_column(namespace, column)
      end
    end
  end

  private

  def sort_by_query_clause(namespace)
    clause = send("#{namespace}_sort_columns").collect do |col|
      "#{col} #{send("#{namespace}_dir_for_column", col)}"
    end.join(", ")

    return if clause.blank?

    Arel.sql(clause)
  end

  def sort_columns(namespace, columns)
    Array.wrap(params["#{namespace}_sort_columns"]).select do |col|
      columns.include?(col) && send("#{namespace}_dir_for_column", col)
    end
  end

  def dir_for_column(namespace, column)
    case params["#{namespace}_#{column}_sorted_by"]
    when "asc"
      "ASC"
    when "desc"
      "DESC"
    when nil
      nil
    end
  end
end
