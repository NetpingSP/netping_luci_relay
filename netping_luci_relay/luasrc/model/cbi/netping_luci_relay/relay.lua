
local config, title = "settings", "Settings"

m = Map(config, title)
m.template = "netping_luci_relay/table"
m.pageaction = false

return m
