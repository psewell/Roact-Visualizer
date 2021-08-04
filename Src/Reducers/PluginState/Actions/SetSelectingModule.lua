--[[
	Sets whether the user is selecting a module.
]]

local main = script:FindFirstAncestor("Roact-Visualizer")
local Action = require(main.Packages.Action)
local Cryo = require(main.Packages.Cryo)
local t = require(main.Packages.t)

local typecheck = t.interface({
	SelectingModule = t.optional(t.literal("FromExplorer", "FromFile", "FromList")),
})

local function create(props)
	assert(typecheck(props))
	return props
end

local function reduce(state, action)
	return Cryo.Dictionary.join(state, {
		SelectingModule = action.SelectingModule or Cryo.None,
	})
end

return Action(script.Name, create, reduce)
