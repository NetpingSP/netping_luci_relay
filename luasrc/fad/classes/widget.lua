

local util = require "luci.util"
local uci = require "luci.model.uci".cursor()
local log = require "luci.fad.utils.log"

Widget = {}
function Widget:new(viewname, Class)
	local pvt = {}
	local pbc = {
		viewname = viewname
	}

	if(pbc.viewname:find(".table.", 1, true) > 0) then
		function pbc:get_columns()
			local columns = {}
			local column = {
				label = '',
				varid = ''
			}
			local ids = Class:ids()
			local instance = Class:load(ids[1])
			local variables = instance:presentedParams(pbc.viewname)
			for i=1, #variables do
				if(variables[i].modifiers[pbc.viewname] ~= nil) then
					column = {}
					column["label"] = variables[i].modifiers[pbc.viewname].label
					column["varid"] = variables[i].modifiers[pbc.viewname].target
					columns[#columns+1] = column
				end
			end
			return(columns)
		end
		
		function pbc:get_rows()
			local rows = {}
			local row = {
				id = '',
				vars = {}
			}
			local instance = {}
			local ids = Class:ids()
			for i=1, #ids do
				instance = Class:load(ids[i])
				row = {}
				row[ids[i]] = instance:presentedParams(pbc.viewname)
				rows[#rows+1] = row
			end
			return(rows)
		end
	elseif(pbc.viewname:find(".modal.", 1, true) > 0) then
		function pbc:get_labels()
			-- TODO
		end
		function pbc:get_options()
			-- TODO
		end
	end

	setmetatable(pbc, self)
	self.__index = self; return pbc;
end

return Widget