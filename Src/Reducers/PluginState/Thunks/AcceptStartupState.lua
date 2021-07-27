--[[
	Accepts the startup state, reloading the autosaved state.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Reducers = main.Src.Reducers
local RemoveStartupState = require(Reducers.PluginState.Actions.RemoveStartupState)
local SetRootModule = require(Reducers.PluginState.Actions.SetRootModule)
local LoadScript = require(Reducers.ScriptTemplates.Thunks.LoadScript)
local DeleteScript = require(Reducers.SavedScripts.Actions.DeleteScript)

return function()
	return function(store)
		local startupState = store:getState().PluginState.StartupState
		if startupState.PropsScripts then
			store:dispatch(LoadScript({
				Name = "AutoSave",
				Container = "PropsScripts",
			}))
			store:dispatch(DeleteScript({
				Name = "AutoSave",
				Container = "PropsScripts",
			}))
		end

		if startupState.RootScripts then
			store:dispatch(LoadScript({
				Name = "AutoSave",
				Container = "RootScripts",
			}))
			store:dispatch(DeleteScript({
				Name = "AutoSave",
				Container = "RootScripts",
			}))
		end

		if startupState.RootModule then
			store:dispatch(SetRootModule({
				RootModule = startupState.RootModule,
			}))
		end

		store:dispatch(RemoveStartupState())
	end
end
