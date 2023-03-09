module Chaltron
  module LogsHelper
    def bootstrap_severity(severity)
      case severity
      when "emerg", "alert", "crit", "err"
        "danger"
      when "warning"
        "warning"
      when "debug"
        "info"
      else
        "primary"
      end
    end
  end
end
