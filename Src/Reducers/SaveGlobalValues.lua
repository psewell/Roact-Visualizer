--[[
	Saves global values to the plugin settings.
]]

local settingsKeys = {
	"FirstLoad",
	"AutoRefresh",
	"AutoRefreshDelay",
	"ShowHelp",
	"MinimalAnimations",
	"AlignCenter",
}

return function(plugin)
	return function(store)
		local state = store:getState()
		for _, key in ipairs(settingsKeys) do
			plugin:SetSetting(key, state.Settings[key])
		end
	end
end
