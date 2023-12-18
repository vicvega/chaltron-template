module Chaltron
  class LogsController < ApplicationController
    include SortAndPaginate
    include Search

    before_action :authenticate_user!
    load_and_authorize_resource

    with_options only: :index do
      preserve :filter, :search, allow_blank: true
      before_action :set_filter
      sort_and_paginate "created_at", "message"
    end

    def index
      @logs = @logs.filter_by(@filter).search_by(search)
      @severities = @logs.group(:severity).count.sort_by { |_k, v| v }.reverse.to_h
      @categories = @logs.group(:category).count.sort_by { |_k, v| v }.reverse.to_h
      @pagy, @logs = pagy(@logs.order("#{sort_column} #{sort_direction}"), items: per_page, page: page)
    end

    def show
    end

    private

    def set_filter
      @filter = Filters::Log.new(filter_params)
    end

    def filter_params
      return {} if params[:filter].blank?

      params[:filter].permit(categories: [], severities: [])
    end
  end
end
