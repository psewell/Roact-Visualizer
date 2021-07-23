--[[
	Performs teardown on the PluginState reducer.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Cryo = require(main.Packages.Cryo)
local Actions = script.Parent.Parent.Actions
local SetThemeConnection = require(Actions.SetThemeConnection)

return function()
	return function(store)
		store:dispatch(SetThemeConnection({
			ThemeConnection = Cryo.None,
		}))
	end
end
