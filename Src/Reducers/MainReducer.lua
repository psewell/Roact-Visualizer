--[[
	Main reducer for all server-side state.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Rodux = require(main.Packages.Rodux)
local Reducers = main.Src.Reducers

return Rodux.combineReducers({
	PluginState = require(Reducers.PluginState.PluginStateReducer),
	Message = require(Reducers.Message.MessageReducer),
	ScriptTemplates = require(Reducers.ScriptTemplates.ScriptTemplatesReducer),
	SavedScripts = require(Reducers.SavedScripts.SavedScriptsReducer),
	Settings = require(Reducers.Settings.SettingsReducer),
})
