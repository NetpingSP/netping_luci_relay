
local config, title = "settings", "Settings"

m = Map(config, title)
m.template = "netping_luci_relay/relay_alert_list"
m.pageaction = false

return m
