--[[
	Loads global values from the plugin settings.
]]

local settingsKeys = {
	"FirstLoad",
	"AutoRefresh",
	"AutoRefreshDelay",
	"ShowHelp",
	"MinimalAnimations",
	"AlignCenter",
}

local main = script:FindFirstAncestor("Roact-Visualizer")
local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)
local SetShowAboutScreen = require(main.Src.Reducers.PluginState.Actions.SetShowAboutScreen)

return function(plugin)
	return function(store)
		local values = {}
		for _, key in ipairs(settingsKeys) do
			local value = plugin:GetSetting(key)
			if value ~= nil then
				values[key] = value
			end
		end
		store:dispatch(SetSetting(values))

		store:flush()
		local settings = store:getState().Settings
		if settings.FirstLoad then
			store:dispatch(SetShowAboutScreen({
				ShowAboutScreen = true,
			}))
			store:dispatch(SetSetting({
				FirstLoad = false,
			}))
		end
	end
end
