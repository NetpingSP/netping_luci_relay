
local util = require "luci.util"
local uci = require "luci.model.uci".cursor()
local Variable = require 'luci.fad.classes.variable'

local Relay = {}
Relay.config = 'netping_relay_adapters'
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
			util.perror("OPTIONS:::::: " .. r[".name"])
			util.dumptable(options)
			for i = 1, #options do
				-- IF option name looks like ".id" then do nothing, else load var
				if((options[i]:sub(1,1) ~= ".") and (options[i]:sub(1,1) ~= "_")) then 
					local varname = id .. "." .. options[i]
					pbc[options[i]] = Variable:load(varname)
				end
			end
		end
	end)

	function pvt:presentedParams(showin) --[[
	INPUT
		'showin' is like 'widget.table.list.relay'
	OUTPUT
		ordered table of relay's params according to order defined with 'oldbrother' uci config option
	]]
		function sortBrothers(group)
			util.perror("SORT_BRO")
			util.dumptable(group)
			local bro, moving_bro, moved, order = nil, nil, false, {}
			for m=1, #group do
				moving_bro = group[m]
				for k=1, #group do
					if(k==m) then break end
					bro =group[k]
					util.perror("OLD BROTHER FOUND: " .. bro.id)
						util.perror("================= ")
					if(moving_bro.modifiers[showin].oldbrother == pvt:dry(bro.id)) then
						

						if((m-k) == 1) then
							moved = true
							break
						end
						
						if(m<k) then
							table.insert(group, k+1, moving_bro)
							group[m] = nil
							util.perror("INSERT+++++++++++++++++++")
						else
							group[m] = nil
							table.insert(group, k+1, moving_bro)
							util.perror("INSERT################")
						end

						moved = true
						break
					end
				end
			end
			if(moved) then
				moved = false
				sortBrothers(group)
			else
				return(group)
			end
		end
		
		--[[ find the oldest brother ]]
		local j = 2
		local ord_params = {}
		for varname, vardata in util.kspairs(pbc) do
			util.perror("VARNAME " .. varname)
			util.dumptable(ord_params)
			-- iterate over relay params
			if(type(vardata) ~= "function") then

				local modifiers = vardata.modifiers
				if(modifiers[showin] ~= nil) then
					util.perror("OLDBRO: " .. modifiers[showin]['oldbrother'])
					if(modifiers[showin]['oldbrother'] == '0') then
						-- set the oldest brother in the first
						j = 1
						ord_params[j] = vardata
					else
						ord_params[j] = vardata
						j = j + 1
					end
					util.perror("ORD_PAR J = " .. j)
					util.dumptable(ord_params)
					ord_params = sortBrothers(ord_params) or {}
				util.perror("LAST CYCLE---------")
				util.dumptable(ord_params)
				end
			end
		end
		retutn(ord_params)
	end
	function pbc:presentedParams(showin)
		return pvt:presentedParams(showin)
	end
	setmetatable(pbc, self)
	self.__index = self; return pbc
end

return Relay