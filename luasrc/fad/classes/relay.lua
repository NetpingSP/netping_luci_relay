
local util = require "luci.util"
local uci = require "luci.model.uci".cursor()
local log = require "luci.fad.utils.log"


local Variable = require 'luci.fad.classes.variable'

local Relay = {}
-- STATIC ATTRS & METHODS
Relay.config = 'netping_relay_adapters'
function Relay:list()
	local all_relays = {}
	uci:foreach(Relay.config, "adapter", function(r)
		local relay = Relay:load(r._id)
		all_relays[r._id] = relay
	end)
	return(all_relays)
end

function Relay:ids()
	local ids = {}
	uci:foreach(Relay.config, "adapter", function(r)
		ids[#ids+1] = r._id
	end)
	return(ids)
end

-- LOAD RELAY WITH VAR PROPERTIES
function Relay:load(id)
	local pvt = { -- PRIVATE
		section = "adapter",
		id = id
	}
	local pbc = {} -- PUBLIC

	function pvt:dry(vn) --[[
		// Dry variable path like this:
		// "relay[1].proto.http[2].address" => "relay[].proto.http[].address"
		]]
		return vn:gsub("[\[\]%d]+", "[]")
	end

	-- get options from uci config
	-- and load approprite variables
	uci:foreach(Relay.config, pvt.section, function(r)
		if(r._id == id) then
			local options = util.keys(r)
			for i = 1, #options do
				-- IF option name looks like ".id" then do nothing, else load var
				if((options[i]:sub(1,1) ~= ".") and (options[i]:sub(1,1) ~= "_")) then 
					local varname = id .. "." .. options[i]
					pbc[options[i]] = Variable:load(varname)
				end
			end
		end
	end)

	function pbc:presentedParams(showin) --[[
	INPUT
		'showin' is like 'widget.table.list.relay'
	OUTPUT
		ordered table of relay's params according to order defined with 'oldbrother' uci config option
	]]
		-- FIND THE OLDEST BROTHER AND COUNT TOTAL NUMS OF BROTHERS
		local total_brothers, presented_params = 0, {};
		for varname, variable in util.kspairs(pbc) do
			if(type(variable) ~= "function") then
				if(variable.modifiers[showin] ~= nil) then
					if(variable.modifiers[showin]['oldbrother'] == '0') then
						presented_params[1] = variable
					end
				end
			end
			total_brothers = total_brothers + 1
		end

		-- ORDER OTHER BROTHERS
		local nearest_oldbrother = presented_params[#presented_params]
		for b=1, total_brothers do
			for varname, variable in util.kspairs(pbc) do
				if(type(variable) ~= "function") then
					if(variable.modifiers[showin] ~= nil) then
						if(variable.modifiers[showin].oldbrother == pvt:dry(nearest_oldbrother.id)) then
							nearest_oldbrother = {}
							nearest_oldbrother = variable
							presented_params[#presented_params+1] = nearest_oldbrother
							break
						end
					end
				end
			end
		end
		return(presented_params)
	end

	setmetatable(pbc, self)
	self.__index = self; return pbc
end

return Relay