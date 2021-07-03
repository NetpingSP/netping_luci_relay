local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.netping.log"
local config = "netping_luci_relay"

local relay = {}
relay.loaded = {}

function relay:new()
	local prototype = uci:get_all(config, "relay_prototype")
	local globals = uci:get_all(config, "globals")
	local count = 0
	uci:foreach(config, "relay", function() count = count + 1 end)
	prototype["name"] = globals["default_name"] .. " " .. count
	prototype["dest_port"] = globals["default_port"]
	prototype["restart_time"] = globals["restart_time"]
	for _, k in pairs({".name", ".anonymous", ".type"}) do prototype[k] = nil end

	uci:section(config, "relay", nil, prototype)
	uci:commit(config)
	relay.loaded = prototype
	return relay.loaded
end

function relay:load()
	return relay.loaded
end

function relay:get(optname)
	return relay.loaded[optname]
end

function relay:set(optname, value)
	local id = relay.loaded[".name"]
	uci:set(config, id, optname, value)
	uci:commit(config)
end

function relay:delete()
	local id = relay.loaded[".name"]
	-- Don't forget to protect embedded relays from deleting
	local embedded = uci:get(config, id, "embedded") == "1"
	if not embedded then
		uci:delete(config, id)
		uci:commit(config)
	end
end

function relay:render(optname)
	local globals = uci:get_all(config, "globals")
	local value = relay.loaded[optname]
	local rendered = {
		-- Render specific representation of these options:
		---------------------------------------------------
		state = function()
			-- Prepare state label, customized with globals setting
			local state_label = {}
			for _, s in pairs(globals["state"]) do
				for k, v in s.gmatch(s, "(%d+)\.(.*)") do
					state_label[k] = v
				end	
			end
			return state_label[value]
		end,

		status = function()
			local status_label = {}
			for _, s in pairs(globals["status"]) do
				for k, v in s.gmatch(s, "(%d+)\.(.*)") do
					status_label[k] = v
				end	
			end
			return status_label[value]
		end,

		embedded = function()
			return relay.loaded["embedded"] == '1' and "Локально" or "Удалённо"
		end,

		-- All trivial options are rendered as is.
		-----------------------------------------
		default = function(optname)
			return relay:get(optname)
		end
	}
	return rendered[optname] ~= nil and rendered[optname]() or rendered['default'](optname)
end

-- Make a Functable to load relay with "relay(id)" style
local metatable = { 
	__call = function(table, ...)
		local id = arg[1] ~= nil and arg[1] or nil
		if id then
			uci:foreach(config, "relay", function(r)
				if (r[".name"] ~= "relay_prototype") then
					if(r[".name"] == id) then
						table.loaded = r
						return
					end
				end
			end)
		end
		return table
	end
}
setmetatable(relay, metatable)


return(relay)