module("luci.controller.netping_luci_relay.index", package.seeall)

local config = "settings"
local http = require "luci.http"
local uci = require "luci.model.uci".cursor()

function index()
	if nixio.fs.access("/etc/config/settings") then
		entry({"admin", "system", "relay"}, cbi("netping_luci_relay/relay"), "Relays", 30)
		entry({"admin", "system", "relay", "action"}, call("do_action"), nil).leaf = true
	end
end

function do_action(action, payload, relay)
	local commands = {
		add = function(...)
			local default_name, count, record = "Relay", 1, {}
			uci:foreach(config, "relay", function() count = count + 1 end)
			record = {
				["name"] = default_name .. " " .. count,
				["state"] = "0",
				["embedded"] = "0",
			}
			uci:section(config, "relay", nil, record)
			uci:commit(config)
		end,
		rename = function(relay, new_name)
			uci:set(config, relay, "name", new_name)
			uci:commit(config)
		end,
		delete = function(relay, ...)
			-- protect embedded relays from deleting
			local embedded = uci:get(config, relay, "embedded") == "1"
			if not embedded then
				uci:delete(config, relay)
				uci:commit(config)
			end
		end,
		switch = function(relay, ...)
			local old_state = tonumber(uci:get(config, relay, "state"))
			local new_state = (old_state + 1) % 2
			uci:set(config, relay, "state", new_state)
			uci:commit(config)
		end,
		default = function(...)
			http.prepare_content("text/plain")
			http.write("0")
		end
	}
	if commands[action] then
		commands[action](relay, payload)
		commands["default"]()
	end
end