--[[
Variable class
local v = Variable:new('relay.memo')
-- 'relay' is adapter varname - uci section
-- 'memo' is variable name - uci option
-- 'relay.memo' - full name (as hierarchical path or address of variable)
]]

local util = require "luci.util"
local uci = require "luci.model.uci".cursor()
local Modifier = require 'luci.fad.classes.modifier'

local Variable = {}
Variable.config = 'netping_relay_adapters'
function Variable:new(varname)
	local pvt = { -- PRIVATE ATTRS & METHODS
		adapter_id 		= nil,
		adapter_param 	= nil,
		section 		= nil
	}
	function pvt:parse(varname)
		local name_chunks =  util.split(varname, ".")
		local l = #name_chunks
		local id = name_chunks[l-1]
		local param = name_chunks[l]
		local sec = util.split(id, "[")[1]; 
		return id, param, sec
	end
	pvt.adapter_id, pvt.adapter_param, pvt.section = pvt:parse(varname)

	function pvt:dry(vn) --[[
		// Dry variable path like this:
		// "relay[1].proto.http[2].address" => "relay[].proto.http[].address"
		]]
		return vn:gsub("[\[\]%d]+", "[]")
	end

	function pvt:getValue()
		local v = ''
		uci:foreach(Variable.config, pvt.section, function(item)
			if (item.id == pvt.adapter_id) then
				v = item[pvt.adapter_param]
				return
			end
		end)
		return v
	end

	function pvt:getModifiers()	--[[
		// get list of modifiers (as tables with options) ]]
		local mdfs, i = {}, 1
		uci:foreach(Modifier.config, "modifier", function(item) 
			if(item.target == pvt:dry(varname)) then
				mdfs[i] = item; i=i+1;
			end
		end)
		return mdfs
	end


	local pbc = {} -- PUBLIC ATTRS & METHODS
	pbc.name = pvt.adapter_param
	pbc.value = pvt:getValue()
	pbc.modifiers = pvt:getModifiers()



	setmetatable(pbc, self)
	self.__index = self; return pbc;
end

return Variable
