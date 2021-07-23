--[[
	Calls the Teardown function for all reducers, if applicable.
]]

local main = script.Parent

return function(plugin)
	return function(store)
		for _, item in ipairs(main:GetDescendants()) do
			if item ~= script and item:IsA("ModuleScript") and item.Name == "Teardown" then
				local teardownThunk = require(item)
				store:dispatch(teardownThunk(plugin))
			end
		end
	end
end
