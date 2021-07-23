--[[
	Main reducer for all server-side state.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Rodux = require(main.Packages.Rodux)
local Reducers = main.Src.Reducers

return Rodux.combineReducers({
	PluginState = require(Reducers.PluginState.PluginStateReducer),
})
