
local util = require 'luci.util'

--F.log(F.filelist({mask = '.js\n'}))

function filelist(pg)
	local ls = util.exec("ls " .. pg.path .. " | grep '" .. pg.grep .. "'")
	ls = util.split(ls, "\n")
	ls[#ls] = nil -- remove blank element
	return ls
end

return(filelist)