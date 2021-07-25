--[[
	Calls the Initialize function for all reducers, if applicable.
]]

local main = script.Parent

local initializeOrder = {
	main.Settings,
	main.ScriptTemplates,
	main.PluginState,
}

return function(plugin)
	return function(store)
		local function initialize(folder)
			local item = folder.Thunks.Initialize
			local initializeThunk = require(item)
			store:dispatch(initializeThunk(plugin))
		end

		for _, folder in ipairs(initializeOrder) do
			initialize(folder)
		end
	end
end
