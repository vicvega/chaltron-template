module Chaltron
  class LogsController < ApplicationController
    include Sortable
    include Paginatable

    helper_method :filter_category, :filter_severity, :filter_search
    before_action :authenticate_user!
    load_and_authorize_resource

    # default_sort_column :created_at
    # default_sort_direction :desc
    permitted_sort_columns Log.column_names

    def index
      @logs = @logs.search(filter_search)
      @logs = @logs.where(category: filter_category) if filter_category
      @logs = @logs.where(severity: filter_severity) if filter_severity

      @logs_group_category = @logs.group(:category).count
      @logs_group_severity = @logs.group(:severity).count

      @pagy, @logs = pagy @logs.order("#{sort_column} #{sort_direction}"), items: per_page
    end

    def show; end

    private

    def filter_search
      params[:search]
    end

    def filter_category
      params[:category]
    end

    def filter_severity
      Log::SEVERITIES.include?(params[:severity]) ? params[:severity] : nil
    end
  end
end
