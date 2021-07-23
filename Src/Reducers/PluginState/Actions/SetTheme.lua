--[[
	Sets the current Studio theme.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Theme = t.instanceIsA("StudioTheme"),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		Theme = action.Theme,
	})
end

return Action(script.Name, create, reduce)
