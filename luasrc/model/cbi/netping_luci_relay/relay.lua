
local config, title = "netping_luci_relay", "Relays"

m = Map(config, title)
m.template = "netping_luci_relay/relay_list"
m.pageaction = false

return m
