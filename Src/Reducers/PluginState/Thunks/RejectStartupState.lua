--[[
	Rejects the startup state, deleting the autosaved state.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Reducers = main.Src.Reducers
local RemoveStartupState = require(Reducers.PluginState.Actions.RemoveStartupState)
local DeleteScript = require(Reducers.SavedScripts.Actions.DeleteScript)

return function()
	return function(store)
		local startupState = store:getState().PluginState.StartupState
		if startupState.PropsScripts then
			store:dispatch(DeleteScript({
				Name = "AutoSave",
				Container = "PropsScripts",
			}))
		end

		if startupState.RootScripts then
			store:dispatch(DeleteScript({
				Name = "AutoSave",
				Container = "RootScripts",
			}))
		end

		store:dispatch(RemoveStartupState())
	end
end
