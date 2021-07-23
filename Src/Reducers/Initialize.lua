--[[
	Calls the Initialize function for all reducers, if applicable.
]]

local main = script.Parent

return function(plugin)
	return function(store)
		for _, item in ipairs(main:GetDescendants()) do
			if item ~= script and item:IsA("ModuleScript") and item.Name == "Initialize" then
				local initializeThunk = require(item)
				store:dispatch(initializeThunk(plugin))
			end
		end
	end
end
