module Chaltron
  class LogsController < ApplicationController
    include Searching
    include Sorting
    include Paginating

    before_action :authenticate_user!
    load_and_authorize_resource

    with_options only: :index do
      preserve :filter, :search, allow_blank: true
      preserve :page, :per_page, :sort_direction, :sort_column
      before_action :set_filter
    end

    def index
      sorts "created_at", "message"
      # sorts "created_at", "message", defaults: {column: "message", direction: "desc"}
      @logs = @logs.filter_by(@filter).search_by(search)
      @severities = count(:severity)
      @categories = count(:category)
      @pagy, @logs = pagy(@logs.order("#{sort_column} #{sort_direction}"), limit: per_page, page:)
    end

    def show
    end

    private

    def count(type)
      db_count = @logs.group(type).count
      I18n.t("chaltron.logs.#{type}").each_with_object({}) do |(k, v), a|
        a[k.to_s] = "#{v} (#{db_count[k.to_s] ||= 0})"
      end.invert
    end

    def set_filter
      @filter = Filters::Log.new(filter_params)
    end

    def filter_params
      return {} if params[:filter].blank?

      params[:filter].permit(categories: [], severities: [])
    end
  end
end
