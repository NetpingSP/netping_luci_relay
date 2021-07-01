--[[
This formula convert relay state value (e.g. '0' or '1') to custom, user friendly string.
It use relay 'state_on', 'state_of' uci setting as source of the friendly strings, 
just like 'Switched OFF' or 'Switched ON'.
----
TODO: the 'formula' modifier, in general, should be rewritten 
to make it like 'toy language' - to be user friendly via web inteface
]]

function CustomState(relay_id)
	local r = require 'luci.fad.classes.relay':load(relay_id)
	local result = ''
	if(r.state.value == '0') then 
		result = r.state_off.value
	end
	if(r.state.value == '1') then 
		result = r.state_on.value
	end
	return result
end
return CustomState