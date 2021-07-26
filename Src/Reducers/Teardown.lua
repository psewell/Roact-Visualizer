--[[
	Calls the Teardown function for all reducers, if applicable.
]]

local main = script.Parent
local SaveGlobalValues = require(main.SaveGlobalValues)
local SaveLocalValues = require(main.SaveLocalValues)

return function(plugin)
	return function(store)
		store:dispatch(SaveGlobalValues(plugin))
		store:dispatch(SaveLocalValues())

		for _, item in ipairs(main:GetDescendants()) do
			if item ~= script and item:IsA("ModuleScript") and item.Name == "Teardown" then
				local teardownThunk = require(item)
				store:dispatch(teardownThunk(plugin))
			end
		end
	end
end
