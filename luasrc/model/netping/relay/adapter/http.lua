local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.netping.log"
local adapter_config = "netping_luci_relay_adapter_http"
local adapter_type = "http"

local http = {}
http.loaded = {}

function http:new(relay_id)
	local template = uci:get_all(adapter_config, "template")
	for _, k in pairs({".name", ".anonymous", ".type"}) do template[k] = nil end

	template["relay"] = relay_id
	uci:section(adapter_config, adapter_type, nil, template)
	uci:commit(adapter_config)
	http.loaded = template
	return http.loaded
end

function http:load()
	return http.loaded
end

function http:get(optname)
	return http.loaded[optname]
end

function http:set(optname, value)
	local id = http.loaded[".name"]
	uci:set(adapter_config, id, optname, value)
	uci:commit(adapter_config)
end

function http:delete()
	local id = http.loaded[".name"]
	uci:delete(adapter_config, id)
	uci:commit(adapter_config)
end

function http:render(optname)
	local value = http.loaded[optname]
	local rendered = {
		-- Render specific representation of these options:
		---------------------------------------------------
		----------- No specific renderes ------------------

		-- All trivial options are rendered as is.
		-----------------------------------------
		default = function(optname)
			return http:get(optname)
		end
	}
	return rendered[optname] ~= nil and rendered[optname]() or rendered['default'](optname)
end

-- Make a Functable to load relay with "relay(id)" style
local metatable = { 
	__call = function(table, ...)
		local id = arg[1] ~= nil and arg[1] or nil
		if id then
			uci:foreach(adapter_config, adapter_type, function(r)
				if (r[".name"] ~= "template") then
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
setmetatable(http, metatable)


return(http)