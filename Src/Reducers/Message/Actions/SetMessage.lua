--[[
	Sets the current Toast message at the bottom of the screen.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local generateId = require(main.Packages.generateId)
local t = require(main.Packages.t)

local typecheck = t.interface({
	Type = t.string,
	Text = t.string,
	Time = t.number,
	Buttons = t.optional(t.table),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		Type = action.Type,
		Text = action.Text,
		Time = action.Time,
		MessageCode = generateId(),
		Buttons = action.Buttons or Cryo.None,
	})
end

return Action(script.Name, create, reduce)
