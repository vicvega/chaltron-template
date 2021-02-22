module Chaltron
  class LogDatatable < AjaxDatatablesRails::ActiveRecord
    extend Forwardable
    attr_reader :view

    def initialize(params, opts = {})
      @view = opts[:view_context]
      super
    end

    def_delegators :@view, :link_to, :tag, :bootstrap_severity, :current_ability

    def view_columns
      # Declare strings in this format: ModelName.column_name
      # or in aliased_join_table.column_name format
      @view_columns ||= {
        severity: { source: 'Chaltron::Log.severity', searchable: false },
        date: { source: 'Chaltron::Log.created_at', searchable: false },
        category: { source: 'Chaltron::Log.category', searchable: false },
        message: { source: 'Chaltron::Log.message' }
      }
    end

    private

    def data
      records.map do |log|
        {
          severity: tag.span(I18n.t("chaltron.logs.severity.#{log.severity}"),
                             class: "badge badge-#{bootstrap_severity(log.severity)}"),
          date: I18n.l(log.created_at, format: :short),
          message: link_to(log.message, log),
          category: I18n.t("chaltron.logs.category.#{log.category}")
        }
      end
    end

    def get_raw_records
      # insert query here
      Chaltron::Log.accessible_by(current_ability)
    end

    # ==== Insert 'presenter'-like methods below if necessary
  end
end
