module("luci.controller.netping_luci_relay.index", package.seeall)

local config = "netping_luci_relay"
local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.netping.log"

local relay = require "luci.model.netping.relay.main"


function notify_backend(action, relay_id, payload)
	util.ubus("netping_relay", "refresh", {action = action, relay_id = relay_id, payload = payload})
end


function index()
	if nixio.fs.access("/etc/config/netping_luci_relay") then
		entry({"admin", "system", "relay"}, cbi("netping_luci_relay/relay"), "Relays", 30)
		entry({"admin", "system", "relay", "action"}, call("do_relay_action"), nil).leaf = true
		entry({"admin", "system", "alerts"}, cbi("netping_luci_relay/alert"), nil).leaf = true
		entry({"admin", "system", "alerts", "action"}, call("do_action"), nil).leaf = true
	end
end


function do_relay_action(action, relay_id)

	local payload = {}
	payload["relay_data"] = luci.jsonc.parse(luci.http.formvalue("relay_data"))
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do payload["relay_data"][k] = nil end
	payload["globals_data"] = luci.jsonc.parse(luci.http.formvalue("globals_data"))

	-- type "logread for debug this:"
	-- if type(payload) == "table" then util.dumptable(payload) else util.perror(payload) end

	local commands = {
		add = function(...)
			relay():new()
		end,
		rename = function(relay_id, payload)
			util.perror(payload["relay_data"]["name"])
			if payload["relay_data"]["name"] then
				relay(relay_id):set("name", payload["relay_data"]["name"])
			end
		end,
		delete = function(relay_id, ...)
			relay(relay_id):delete()
		end,
		switch = function(relay_id, ...)
			local old_state = tonumber(uci:get(config, relay_id, "state"))
			local new_state = (old_state + 1) % 2
			relay(relay_id):set("state", new_state)
		end,
		edit = function(relay_id, payloads)
			-- apply settings.<relay_id>
			local allowed_relay_options = util.keys(uci:get_all(config, "relay_prototype"))
			for key, value in pairs(payloads["relay_data"]) do
				if util.contains(allowed_relay_options, key) then
					uci:set(config, relay_id, key, value)
				end
				uci:commit(config)
			end
			-- apply settings.globals
			local allowed_global_options = util.keys(uci:get_all(config, "globals"))
			for key, value in pairs(payloads["globals_data"]) do
				if util.contains(allowed_global_options, key) then
					if type(value) == "table" then
						uci:set_list(config, "globals", key, value)
					else
						uci:set(config, "globals", key, value)
					end
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
		commands[action](relay_id, payload)
		commands["default"]()
		notify_backend(action, relay_id, util.serialize_json(payload))
	end
end


function do_alert_action(action, alert_id)
	local payload = {}
	payload["alert_data"] = luci.jsonc.parse(luci.http.formvalue("alert_data"))
	local commands = {
		add = function(...)

		end,
		delete = function(alert_id, ...)

		end,
		edit = function(alert_id, payloads)

		end,
		default = function(...)
			http.prepare_content("text/plain")
			http.write("0")
		end
	}
	if commands[action] then
		commands[action](alert_id, payload)
		commands["default"]()
	end
end
