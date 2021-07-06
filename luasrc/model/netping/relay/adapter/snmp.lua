local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local log = require "luci.model.netping.log"
local adapter_config = "netping_luci_relay_adapter_snmp"
local adapter_type = "snmp"

local snmp = {}
snmp.loaded = {}

function snmp:new(relay_id)
	local template = uci:get_all(adapter_config, "template")
	for _, k in pairs({".name", ".anonymous", ".type"}) do template[k] = nil end

	template["relay"] = relay_id
	uci:section(adapter_config, adapter_type, nil, template)
	uci:commit(adapter_config)
	snmp.loaded = template
	return snmp.loaded
end

function snmp:load()
	return snmp.loaded
end

function snmp:get(optname)
	return snmp.loaded[optname]
end

function snmp:set(optname, value)
	local id = snmp.loaded[".name"]
	uci:set(adapter_config, id, optname, value)
	uci:commit(adapter_config)
end

function snmp:delete()
	local id = snmp.loaded[".name"]
	uci:delete(adapter_config, id)
	uci:commit(adapter_config)
end

function snmp:render(optname)
	local value = snmp.loaded[optname]
	local rendered = {
		-- Render specific representation of these options:
		---------------------------------------------------
		hostport = function()
			return snmp:get("host") .. ":" .. snmp:get("port")
		end,

		cssfile = function()
			local path = util.libpath() .. '/view/netping_luci_relay/ui_adapter/snmp.css.htm'
			return fs.readfile(path)
		end,

		jsinit = function()
			return "var adapter_snmp = new ui.AdapterSNMP(relay_id)"
		end,

		jsrender = function()
			return "adapter_snmp.render()"
		end,

		widgetfile = function()
			local path = util.libpath() .. '/view/netping_luci_relay/ui_adapter/UIAdapterSNMP.js.htm'
			return fs.readfile(path)
		end,


		-- All trivial options are rendered as is.
		-----------------------------------------
		default = function(optname)
			return snmp:get(optname)
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
		else -- loads protocol template data if 'id' is absent
			uci:foreach(adapter_config, adapter_type, function(r)
				if (r[".name"] == "template") then
					table.loaded = r
					return
				end
			end)
		end
		return table
	end
}
setmetatable(snmp, metatable)


return(snmp)