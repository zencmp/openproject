# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

##
# Abstract view component. Subclass this for a concrete table.
class TableComponent < RailsComponent
  include SortHelper
  include PaginationHelper

  attr_reader :model

  def initialize(rows:, **options)
    super(**options)
    @model = rows
  end

  class << self
    # Declares columns shown in the table.
    #
    # Use it in subclasses like so:
    #
    #     columns :name, :description, :sort
    #
    # When table is sortable, the column names are used by sort logic. It means
    # these names will be used directly in the generated SQL queries.
    def columns(*names)
      return Array(@columns) if names.empty?

      @columns = names.map(&:to_sym)
    end

    ##
    # Define which of the registered columns are sortable
    # Applies only if +sortable?+ is true
    def sortable_columns(*names)
      if names.present?
        @sortable_columns = names.map(&:to_sym)
        # set available criteria
        return
      end

      # return all columns unless defined otherwise
      if @sortable_columns.nil?
        columns
      else
        Array(@sortable_columns)
      end
    end

    def add_column(name)
      @columns = Array(@columns) + [name]
      row_class.property name
    end

    def row_class
      mod = name.split("::")[0..-2].join("::").presence || "Table"

      "#{mod}::RowComponent".constantize
    rescue NameError
      raise(
        NameError,
        "#{mod}::RowComponent required by #{mod}::TableComponent not defined. " +
        "Expected to be defined in `app/components/#{mod.underscore}/row_component.rb`."
      )
    end
  end

  def before_render
    initialize_sorted_model if sortable?
  end

  def initialize_sorted_model
    sort_init *initial_sort.map(&:to_s)
    sort_update sortable_columns.map(&:to_s)
    @model = paginate_collection apply_sort(model)
  end

  def apply_sort(model)
    case model
    when ActiveRecord::QueryMethods
      sort_collection(model, sort_clause)
    when Queries::BaseQuery
      model
        .order(@sort_criteria.to_query_hash)
        .results
    else
      raise ArgumentError, "Cannot sort the given model class #{model.class}"
    end
  end

  ##
  # Sorts the data to be displayed.
  #
  # @param query [ActiveRecord::QueryMethods] An active record collection.
  # @param sort_clause [String] The SQL used as the sort clause.
  def sort_collection(query, sort_clause)
    query
      .reorder(sort_clause)
      .order(Arel.sql(initial_order))
  end

  def paginate_collection(query)
    query
      .page(page_param(controller.params))
      .per_page(per_page_param)
  end

  def rows
    model
  end

  def row_class
    self.class.row_class
  end

  def columns
    self.class.columns
  end

  def sortable_columns
    self.class.sortable_columns
  end

  def render_row(row)
    render(row_class.new(row:, table: self))
  end

  def initial_sort
    [columns.first, :asc]
  end

  def initial_order
    initial_sort.join(' ')
  end

  def paginated?
    rows.respond_to? :total_entries
  end

  def inline_create_link
    nil
  end

  def sortable?
    true
  end

  def sortable_column?(column)
    sortable? && sortable_columns.include?(column.to_sym)
  end

  def empty_row_message
    I18n.t :no_results_title_text
  end
end
