--[[
	Sets the current Toast message at the bottom of the screen.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local generateId = require(main.Packages.generateId)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Text = t.string,
	Time = t.number,
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		Text = action.Text,
		Time = action.Time,
		MessageCode = generateId(),
	})
end

return Action(script.Name, create, reduce)
