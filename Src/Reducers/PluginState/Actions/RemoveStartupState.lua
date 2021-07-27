--[[
	Removes the Startup state.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)

local function create()
	return {}
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		StartupState = Cryo.None,
	})
end

return Action(script.Name, create, reduce)
