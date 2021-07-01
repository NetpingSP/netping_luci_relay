
local util = require "luci.util"
local uci = require "luci.model.uci".cursor()
local log = require "luci.fad.utils.log"


local UIbus = {}
-- STATIC ATTRS & METHODS
function UIbus:init(events, class)
	local pbc, pvt = {}, {}

	function pvt:renderUibus()
		local chunk = [[
			<script type="text/javascript">
			//<![CDATA[
			function bus_relay_setting_open(/* ... */) {
				var args = {}
				window.EventBus.node.dispatchEvent(new CustomEvent("bus-relay-setting-open", {
					detail: { "relay": "relay[1]" }
				}));
			}
			]] .. '//]]></script>'
		return(chunk)
	end

	function pbc:load()
		return(pvt:renderUibus())
	end

	function pbc:dispatch(event, params)
		local funcname = table.concat(util.split(event, "-"), "_") .. "()"
		local json_params = util.serialize_json(params)

		return(funcname)
	end

	setmetatable(pbc, self)
	self.__index = self; return pbc;
end

return UIbus