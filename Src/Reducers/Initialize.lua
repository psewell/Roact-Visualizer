--[[
	Calls the Initialize function for all reducers, if applicable.
]]

local main = script.Parent
local LoadLocalValues = require(main.LoadLocalValues)
local LoadGlobalValues = require(main.LoadGlobalValues)

local initializeOrder = {
	main.Settings,
	main.ScriptTemplates,
	main.PluginState,
}

return function(plugin)
	return function(store)
		store:dispatch(LoadLocalValues())
		store:dispatch(LoadGlobalValues(plugin))

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
