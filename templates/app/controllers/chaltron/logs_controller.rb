module Chaltron
  class LogsController < ApplicationController
    include Paginatable
    include Sortable
    before_action :authenticate_user!
    load_and_authorize_resource

    permitted_sort_columns %w[created_at message]

    def index
      @filter = Log::Filter.new(filter_params)
      @logs = @filter.apply(@logs).order("#{sort_column} #{sort_direction}")

      @severities = @logs.group(:severity).count.sort_by { |_k, v| v }.reverse.to_h
      @categories = @logs.group(:category).count.sort_by { |_k, v| v }.reverse.to_h
      @pagy, @logs = pagy(@logs, items: per_page, page: page)
    end

    def show; end

    private

    def filter_params
      return {} if params[:filter].blank?

      params[:filter].permit(:search, categories: [], severities: [])
    end
  end
end
