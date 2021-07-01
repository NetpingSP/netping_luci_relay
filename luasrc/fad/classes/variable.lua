--[[
Variable class
local v = Variable:load('relay.memo')
-- 'relay' is adapter varname - uci section
-- 'memo' is variable name - uci option
-- 'relay.memo' - full name (as hierarchical path or address of variable)
]]

local util = require "luci.util"
local uci = require "luci.model.uci".cursor()
local log = require "luci.fad.utils.log"
local Modifier = require 'luci.fad.classes.modifier'
local nixio = require 'nixio'
local sys = require 'luci.sys'

local Variable = {}
Variable.config = 'netping_relay_adapters'
function Variable:load(varname)
	local pbc = {} 
	local pvt = { 
		adapter_id 		= nil,
		adapter_param 	= nil,
		section 		= "adapter"
	}

	-- PRIVATE ATTRS & METHODS
	function pvt:parse(varname) --[[
	INPUT: 
		varname is like this: 'relay[1].proto.http[1].address'
		relay[1] - is relay adapter identifier
		proto - param 'protocol' of the adapter
		http[1] - is protocol adapter of 'http' type with identifier 'http[1]'
		adress - param of the http protocol adapter
	OUTPUT:
		id - 'http[1]''
		param - 'address'
	]]
		local name_chunks =  util.split(varname, ".")
		local l = #name_chunks
		local id = name_chunks[l-1]
		local param = name_chunks[l]
		--local sec = util.split(id, "[")[1]; 
		return id, param
	end
	pvt.adapter_id, pvt.adapter_param = pvt:parse(varname)


	function pvt:dry(vn) --[[
		// Dry variable path like this:
		// "relay[1].proto.http[2].address" => "relay[].proto.http[].address"
		]]
		return vn:gsub("[\[\]%d]+", "[]")
	end

	function pvt:getValue()
		local v = ''
		uci:foreach(Variable.config, pvt.section, function(item)
			if (item._id == pvt.adapter_id) then
				v = item[pvt.adapter_param]
				return
			end
		end)
		return v
	end

	function pvt:modFormula(formula) --[[
	INPUT: 	formula name, e.g.: 'CustomState()', defined in config as 'modifier' of the variable
	TODO: there will be a parser here later, because the formula has to be simplier
	]]
		local result = nil
		local adapter_id = util.split(pbc.id, ".")[1]
		local custom_state = require 'luci.fad.modifiers.formula.CustomState()'
		result = custom_state(adapter_id)

		return(result)
	end

	function pvt:getModifiers()	--[[
		// get list of modifiers (as tables with options) ]]
		local mdfs, mdfkey, i = {}, '', 1
		uci:foreach(Modifier.config, "modifier", function(item) 
			if(item.target == pvt:dry(varname)) then
				mdfkey = item.showin or tostring(i)
				mdfs[mdfkey] = item; i=i+1;
			end
		end)
		--if (#mdfs == 0) then mdfs = nil end

		return mdfs
	end

	-- PUBLIC ATTRS & METHODS
	pbc.id = varname
	pbc.name = pvt.adapter_param
	pbc.value = ''
	pbc.modifiers = pvt:getModifiers()


	function pbc:render(showin)
		local rendered = pbc.value
		if (pbc.modifiers[showin].formula ~= nil) then
			rendered = pvt:modFormula(pbc.modifiers[showin].formula) or pbc.value
		end
		return(rendered)
	end

	function pbc:setValue(val)
		--TODO
	end

	setmetatable(pbc, self)
	self.__index = self
	pbc.value = pvt:getValue()
	return pbc
end

return Variable
