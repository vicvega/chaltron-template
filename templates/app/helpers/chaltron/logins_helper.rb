module Chaltron::LoginsHelper
  def device_details(login)
    return if login.user_agent.nil?

    device = DeviceDetector.new(login.user_agent)
    os = [device.os_name, device.os_full_version].compact.join(" ")
    browser = [device.name, device.full_version].compact.join(" ")
    [device.device_type, os, browser].join(" / ")
  end
end
