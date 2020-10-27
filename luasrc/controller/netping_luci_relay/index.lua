module("luci.controller.netping_luci_relay.index", package.seeall)

local config = "settings"
local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"


function index()
	if nixio.fs.access("/etc/config/settings") then
		entry({"admin", "system", "relay"}, cbi("netping_luci_relay/relay"), "Relays", 30)
		entry({"admin", "system", "relay", "action"}, call("do_action"), nil).leaf = true
	end
end

function do_action(action, relay)
	local payload = luci.http.formvalue()
	local allowed_options = util.keys(uci:get_all(config, "prototype"))
	local commands = {
		add = function(...)
			local default_name = uci:get(config, "globals", "default_name")
			local count, record = 1, {}
			uci:foreach(config, "relay", function() count = count + 1 end)
			record = {
				["name"] = default_name .. " " .. count
			}
			uci:section(config, "relay", nil, record)
			uci:commit(config)
		end,
		rename = function(relay, payload)
			if payload["name"] then
				uci:set(config, relay, "name", payload["name"])
				uci:commit(config)
			end
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
		edit = function(relay, payload)
			for key, value in payload do
				if util.contains(allowed_payloads, key) then
					uci:set(config, relay, key, value)
				end
				uci:commit(config)
			end
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