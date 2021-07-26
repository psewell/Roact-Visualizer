--[[
	Initializes the PluginState Reducer.
]]

local Actions = script.Parent.Parent.Actions
local SetTheme = require(Actions.SetTheme)
local SetThemeConnection = require(Actions.SetThemeConnection)
local SetRoactInstall = require(Actions.SetRoactInstall)

return function(plugin)
	return function(store)
		store:dispatch(SetTheme({
			Theme = settings().Studio.Theme,
		}))
		local themeConnection = settings().Studio.ThemeChanged:Connect(function()
			store:dispatch(SetTheme({
				Theme = settings().Studio.Theme,
			}))
		end)

		store:dispatch(SetThemeConnection({
			ThemeConnection = themeConnection,
		}))

		store:dispatch(SetRoactInstall({
			RoactInstall = game.ReplicatedStorage.Packages.ThirdPartyRoact,
		}))
	end
end
