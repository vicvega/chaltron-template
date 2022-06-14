module Chaltron
  module LogsHelper
    def bootstrap_severity(severity)
      case severity.to_s
      when 'emerg', 'alert', 'crit', 'err'
        'danger'
      when 'warning'
        'warning'
      when 'debug'
        'info'
      else
        'primary'
      end
    end

    def logs_ssfp_params
      # search, sort, filter and paginate params
      request.params.slice(:page, :per_page, :sort_column, :sort_direction, :severity, :category, :search)
    end
  end
end
