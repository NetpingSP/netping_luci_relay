--[[
local util = require "luci.util"
local flist = require "luci.model.netping.relay.filelist"
local uci = require "luci.model.uci".cursor()
local log = require "luci.model.netping.log"

local adapter_path = util.libpath() .. "/model/netping/relay/adapter"

local list = {}
list.loaded = {} 
list.loaded = {
	snmp = {
		config = "netping_relay_adapter_snmp",
		model = require("luci.model.netping.relay.adapter.snmp")
	}
}


function list:new(relay_id)

end

local metatable = { 
	__call = function(table)
		local at, adapter_type = {}, ''
		local adapter_models = {}

		for i=1, #files do
			adapter_type = util.split(files[i], '.lua')[1]
			adapter_models[adapter_type] = require("luci.model.netping.relay.adapter." .. adapter_type)
		end

		
		return table
	end
}
setmetatable(http, metatable)


return(http)
]]