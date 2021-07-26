--[[
	Loads global values from the plugin settings.
]]

local settingsKeys = {
	"AutoRefresh",
	"AutoRefreshDelay",
	"ShowHelp",
	"MinimalAnimations",
	"AlignCenter",
}

local main = script:FindFirstAncestor("Roact-Visualizer")
local SetSetting = require(main.Src.Reducers.Settings.Actions.SetSetting)

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
	end
end
